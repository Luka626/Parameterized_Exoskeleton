classdef main < matlab.apps.AppBase

    % App component properties
    properties (Access = public)
        UIFigure matlab.ui.Figure;
        HeightEntry matlab.ui.control.NumericEditField;
        WeightEntry matlab.ui.control.NumericEditField;
        AgeEntry matlab.ui.control.NumericEditField;
    end

    properties (Access = private)
        GridManager matlab.ui.container.GridLayout;
        UserInputsPanel;
        InputGrid matlab.ui.container.GridLayout;
        RenderPanel;
        Cfg struct;
        Render;
    end
    
    % Callbacks and Initializations
    methods (Access = private)

        % App and component initialization
        function createComponents(app)

            setConfig(app);
            
            % Create invisible UI Figure
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Name = "EldoSaver";
            app.UIFigure.Position = [100 100 app.Cfg.app_width app.Cfg.app_height];

            app.GridManager = uigridlayout(app.UIFigure, [1,2]);
            app.GridManager.RowHeight = {'0.55x'};
            app.GridManager.ColumnWidth = {'2x', '1x'};


            app.RenderPanel = uipanel(app.GridManager, "Title", "Render");
            app.Render = uiimage(app.RenderPanel);
            app.Render.ImageSource = "img_tmp.jpg";
            app.Render.ScaleMethod = 'scaleup';

            app.UserInputsPanel = uipanel(app.GridManager, "Title", "User Inputs");

            app.InputGrid = uigridlayout(app.UserInputsPanel, [3,1]);

            % Create Height Entry Component
            app.HeightEntry = uieditfield(app.InputGrid, "numeric");
            app.HeightEntry.ValueChangedFcn = createCallbackFcn(app, @changeUserHeight, true);

            app.WeightEntry = uieditfield(app.InputGrid, "numeric");

            app.AgeEntry = uieditfield(app.InputGrid, "numeric");

            % Make UI visible after all components have loaded
            app.UIFigure.Visible = "on";
        end

        function setConfig(app)
            app.Cfg = struct(...
                'app_width', {960}, ...
                'app_height', {720}, ...
                'ht_max', {2}, ...
                'ht_min', {1.5}); 
        end

        function changeUserHeight(~, event)
            new_ht = event.Value;
            system_design({});
        end
    end

    methods (Access = public)

        function app = main
            createComponents(app);
            registerApp(app, app.UIFigure);

            if nargout == 0
                clear app;
            end
        end

        function delete(app)
            delete(app.UIFigure);
        end
    end
end
