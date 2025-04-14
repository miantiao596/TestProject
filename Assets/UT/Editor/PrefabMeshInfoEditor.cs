    //using UnityEditor;
    //using UnityEngine;

    //[CustomEditor(typeof(GameObject), true)]
    //public class PrefabMeshInfoEditor : Editor
    //{
    //    private int totalVertexCount = 0;
    //    private int totalTriangleCount = 0;
    //    private Editor previewEditor;

    //    public override bool HasPreviewGUI()
    //    {
    //        return true;
    //    }
    //    public override void OnPreviewGUI(Rect r, GUIStyle background)
    //    {
    //        GUI.Label(r, target.name + " is being previewed");


    //        // 绘制预览图（确保正确的上下文）
    //        if (previewEditor != null)
    //        {
    //            Rect previewRect = GUILayoutUtility.GetRect(100, 100, GUILayout.ExpandWidth(true), GUILayout.ExpandHeight(true));
    //            // 绘制目标对象的预览
    //            previewEditor.OnPreviewGUI(previewRect, EditorStyles.helpBox);
    //        }


    //        // 显示顶点和三角形数量信息
    //        EditorGUILayout.Space();
    //        EditorGUILayout.LabelField("Mesh Info:", EditorStyles.boldLabel);
    //        EditorGUILayout.LabelField($"Total Vertex Count: {totalVertexCount}");
    //        EditorGUILayout.LabelField($"Total Triangle Count: {totalTriangleCount}");

    //    }
    //    //public override void OnInspectorGUI()
    //    //{
    //    //    // 打印日志，确认 OnInspectorGUI 是否被调用
    //    //    Debug.Log($"OnInspectorGUI executed for {target.name}");

    //    //    // 绘制预览图（确保正确的上下文）
    //    //    if (previewEditor != null)
    //    //    {
    //    //        Rect previewRect = GUILayoutUtility.GetRect(100, 100, GUILayout.ExpandWidth(true), GUILayout.ExpandHeight(true));
    //    //        // 绘制目标对象的预览
    //    //        previewEditor.OnPreviewGUI(previewRect, EditorStyles.helpBox);
    //    //    }

    //    //    // 默认的 Inspector 视图
    //    //    base.DrawDefaultInspector();

    //    //    // 强制更新视图，重新绘制 Inspector
    //    //    Repaint();  // 强制刷新

    //    //    // 显示顶点和三角形数量信息
    //    //    EditorGUILayout.Space();
    //    //    EditorGUILayout.LabelField("Mesh Info:", EditorStyles.boldLabel);
    //    //    EditorGUILayout.LabelField($"Total Vertex Count: {totalVertexCount}");
    //    //    EditorGUILayout.LabelField($"Total Triangle Count: {totalTriangleCount}");

    //    //    // 强制刷新面板
    //    //    EditorUtility.SetDirty(target);
    //    //}
    //}
