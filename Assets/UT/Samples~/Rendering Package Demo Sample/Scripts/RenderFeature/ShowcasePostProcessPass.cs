using System.Linq;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using System.Collections.Generic;

namespace UT.Rendering
{
    public class ShowcaseProcessPass : ScriptableRenderPass
    {
        // 获取后处理基类列表
        private List<ShowcaseProcessing> mShowcaseProcessings;
        private List<int> mShowcaseProcessingIndex;         // 存储当前激活的自定义后处理效果的索引

        // 声明RT
        private RTHandle mSourceRT;
        private RTHandle mDesRT;
        private RTHandle mTempRT0;
        private RTHandle mTempRT1;
        private string mTempRT0Name => "_TemporaryRenderTexture0";
        private string mTempRT1Name => "_IntermediateRenderTarget1";


        // 性能分析的标签
        private string m_ProfilerTag; // 确保这样的声明存在
        private List<ProfilingSampler> m_ProfilingSamplers;   // 用于监控每个自定义后处理效果的性能


        // 相机初始化时执行
        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            var descriptor = renderingData.cameraData.cameraTargetDescriptor;
            descriptor.msaaSamples = 1;
            descriptor.depthBufferBits = 0;

            // 分配临时纹理
            RenderingUtils.ReAllocateIfNeeded(ref mTempRT0, descriptor, name: mTempRT0Name);
            RenderingUtils.ReAllocateIfNeeded(ref mTempRT1, descriptor, name: mTempRT1Name);

            foreach (var i in mShowcaseProcessingIndex)
            {
                mShowcaseProcessings[i].OnCameraSetup(cmd, ref renderingData);
            }
        }

        // 相机清除时执行
        public override void OnCameraCleanup(CommandBuffer cmd)
        {
            mDesRT = null;
            mSourceRT = null;
        }



        // 确定哪些后处理效果是激活的，通过调用它们的 Setup 方法和检查它们的激活状态 (IsActive())
        public bool SetupPostProcessing()
        {
            mShowcaseProcessingIndex.Clear();

            for (int i = 0; i < mShowcaseProcessings.Count; i++)
            {
                mShowcaseProcessings[i].Setup();

                if (mShowcaseProcessings[i].IsActive())
                {
                    mShowcaseProcessingIndex.Add(i);
                }
            }
            return mShowcaseProcessingIndex.Count != 0;

        }

        //
        public ShowcaseProcessPass(string ProfilerTag, List<ShowcaseProcessing> ShowcaseProcessing)
        {
            m_ProfilerTag = ProfilerTag;
            mShowcaseProcessings = ShowcaseProcessing;

            mShowcaseProcessingIndex = new List<int>(ShowcaseProcessing.Count);                      // 初始化后处理效果索引列表
            m_ProfilingSamplers = ShowcaseProcessing.Select(c => new ProfilingSampler(c.ToString())).ToList();   // 性能采样器列表

        }

        // 执行逻辑
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            if (!SetupPostProcessing()) return;

            //初始化 commandbuffer
            var cmd = CommandBufferPool.Get(m_ProfilerTag);
            context.ExecuteCommandBuffer(cmd);
            cmd.Clear();




            // 设置源和目标RT为本次渲染的RT 在Execute里进行 特殊处理后处理后注入点
            mDesRT = renderingData.cameraData.renderer.cameraColorTargetHandle;
            mSourceRT = renderingData.cameraData.renderer.cameraColorTargetHandle;





            // 根据激活后处理数量执行不同的渲染策略

            if (mShowcaseProcessingIndex.Count == 1)
            {
                // 激活 一个后处理
                // 如果只有一个激活的后处理，直接在 mTempRT0 上渲染。
                int index = mShowcaseProcessingIndex[0];
                using (new ProfilingScope(cmd, m_ProfilingSamplers[index]))
                {
                    mShowcaseProcessings[index].Render(cmd, ref renderingData, mSourceRT, mTempRT0);
                }
            }
            else
            {
                // 激活多个后处理
                // 如果有多个激活的后处理，依次在 mTempRT0 和 mTempRT1 之间交换并渲染。

                Blitter.BlitCameraTexture(cmd, mSourceRT, mTempRT0);
                for (int i = 0; i < mShowcaseProcessingIndex.Count; i++)
                {
                    int index = mShowcaseProcessingIndex[i];
                    var customProcessing = mShowcaseProcessings[index];

                    using (new ProfilingScope(cmd, m_ProfilingSamplers[index]))
                    {
                        customProcessing.Render(cmd, ref renderingData, mTempRT0, mTempRT1);
                    }


                    CoreUtils.Swap(ref mTempRT0, ref mTempRT1);
                }
            }
            Blitter.BlitCameraTexture(cmd, mTempRT0, mDesRT);

            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);

        }

        // 释放临时纹理
        public void Dispose()
        {
            RTHandles.Release(mTempRT0);
            RTHandles.Release(mTempRT1);
        }

    }
}
