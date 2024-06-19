classdef TreeMenu < handle% & ThemedComponent
    
    properties
        TreeStruct
        SelectionChangedFcn
    end

    properties (Access = private)
        UITree matlab.ui.container.Tree
        UITreeNodes matlab.ui.container.TreeNode
    end
    
    methods
        function obj = TreeMenu(parent, treeStruct, theme)
            
            gl = uigridlayout(parent, 'Padding',0, 'ColumnWidth',{'1x'}, 'RowHeight',{'1x'});
            obj.UITree = uitree(gl);
            obj.UITree.SelectionChangedFcn = @obj.onSelectedItemChanged;

            %obj.UITree.FontColor = theme.FigureFgColor;
            %obj.UITree.BackgroundColor = theme.FigureBgColor;

            obj.addNodes(obj.UITree, treeStruct);

            drawnow
            try
                ccTools.compCustomization(obj.UITree, 'borderWidth', '0px')
            end
        end
    end
    methods (Access = private)
        function addNodes(obj, parentNode, treeStruct)

            for i = 1:numel(treeStruct.children)
                iChild = treeStruct.children{i};
                iNode = uitreenode(parentNode);
                iNode.Text = iChild.name;
                iNode.Tag = iChild.fullName;

                if isempty(iChild.children)
                    %continue
                else
                    obj.addNodes(iNode, iChild)
                end
            end
        end
    
        function onSelectedItemChanged(obj, ~, evt)
            
            nodeFullName = evt.SelectedNodes.Tag;

            if ~isempty(obj.SelectionChangedFcn)
                obj.SelectionChangedFcn(evt, nodeFullName);
            end
        end
    end
end
