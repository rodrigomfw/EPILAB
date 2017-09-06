%This class builds the graphical interface of Artificial Neural Networks
%predictions algorithms
classdef Artificial_Neural_Networks_Interface < handle
    
    properties
        panel;
        menus;
        th_lev_edit;
        fig;
        panel_title = 'Artificial Neural Networks';
        
        
        NNET;
        
        %Graphical User Interface auxiliar variables (normalized)
        DEFAULT_EDIT_WIDTH = 0.075;
        DEFAULT_EDIT_HEIGHT = 0.10;
        
        DEFAULT_TEXT_HEIGHT = 0.10;
        DEFAULT_TEXT_WIDTH = 0.30;
        
        DEFAULT_POPUP_HEIGHT = 0.10;
        DEFAULT_POPUP_WIDTH = 0.20;
        
        DEFAULT_SEPARATION = 0.03;
        
        NNET_PANEL_WIDTH = 0.98;
        NNET_PANEL_HEIGHT = 0.6;
        NNET_PANEL_X = 0.01;
        NNET_PANEL_Y = 0.01;
        
        DATA_PANEL_HEIGHT = 0.2;
        
        
        %Classes
        FUNCTIONS;  %Reference to the Functions Class
        DATA; %Reference to the Data Class
        STUDY;
    end
    
    methods
        
        %Constructor
        function obj = Artificial_Neural_Networks_Interface(study)
            import PredictionAlgorithms.Artificial_Neural_Networks.*;
            
            obj.STUDY = study;
            obj.DATA = Artificial_Neural_Networks_Data();
            obj.DATA.STUDY = study;
            obj.FUNCTIONS = Artificial_Neural_Networks_Functions(obj.DATA);
        end
        
        
        %Method that builds the Graphical User Interface Components
        %params: panel (uipanel where all the uicomponents are drawn)
        function draw(obj, panel)
            
            global h;
            
            set(panel,'Title',obj.panel_title, 'TitlePosition','centertop');
            
            data_panel = uipanel('Parent',panel,'Title','Select Data','ForegroundColor',[4/255 166/255 146/255],'FontWeight','bold','Units','Normalized','FontSize',10,'Position',[0,0.8,0.58,obj.DATA_PANEL_HEIGHT]);
            drawDataPanel(data_panel);
            
            perf_panel = uipanel('Parent',panel,'Title','ANN Results','ForegroundColor',[4/255 166/255 146/255],'FontWeight','bold','Units','Normalized','FontSize',10,'Position',[0.585,0.8,0.4,obj.DATA_PANEL_HEIGHT]);
            drawPerfPanel(perf_panel);
            
            %perf_al_panel = uipanel('Parent',panel,'Title','Alarm Performance','ForegroundColor',[4/255 166/255 146/255],'FontWeight','bold','Units','Normalized','FontSize',10,'Position',[0.8,0.8,0.2,obj.DATA_PANEL_HEIGHT]);
            %drawPerfPanelAl(perf_al_panel);
            
            training_panel = uipanel('Parent',panel,'Title','Training','ForegroundColor',[4/255 166/255 146/255],'FontWeight','bold','Units','Normalized','FontSize',10,'Position',[0,0,1,0.8]);
            
            nets=obj.DATA.NNETS;
            
            h.network_type_text = uicontrol('Parent',training_panel,'Style','text','Units','Normalized','String','Network type:','FontSize',10,'Position',[0,0.7,0.25,0.2]);
            h.network_type_popup = uicontrol('Parent',training_panel,'Style','popupmenu','Units','Normalized','String',nets,'BackgroundColor','white','Position',[0.25,0.7,0.35,0.2],'Callback',{@networktype_Callback});
            
            if obj.DATA.loading %If Results window is loading this algorithm, select the correct ANN
                count = 1;
                
                net = char(obj.DATA.saveinfo_name);
                net = net(find(net == '.')+1:end);
                
                for j=1:length(nets)
                    if strcmp(nets{j},net)
                        break;
                    end
                    count = count + 1;
                end
                
                set(h.network_type_popup,'Value',count);
                selectNetwork_panel = create_netPanel(net, training_panel);
            else
                selectNetwork_panel = create_netPanel(nets(1),training_panel);
            end
            
            %Select the correct ANN panel
            function networktype_Callback(source,eventdata)
                
                str = get(source, 'String');
                val = get(source, 'Value');
                net = str{val};
                
                %Delete the old panel
                set(selectNetwork_panel,'Visible','off');
                delete(selectNetwork_panel);
                
                %Build a new panel
                selectNetwork_panel=create_netPanel(net,training_panel);
            end
            
            %Draw the data panel
            function drawDataPanel(data_panel)
                
                h.ANN.open_dataset_button = uicontrol('Parent',data_panel,'Style','pushbutton','Units','Normalized','String','Open','FontSize',8,'Callback',{@OpenDataSet_Button},...
                    'Position',[0.03,0.01,0.1,0.25]);
                
                h.ANN.delete_button = uicontrol('Parent',data_panel,'Style','pushbutton','Units','Normalized','String','Del','FontSize',8,'Enable','Off','Callback',{@Delete_Button},...
                    'Position',[0.03+0.1,0.01,0.07,0.25]);
                
                h.ANN.refresh_button = uicontrol('Parent',data_panel,'Style','pushbutton','Units','Normalized','String','Refresh','FontSize',8,'Enable','On','Callback',{@LoadStudyDatasets},...
                    'Position',[0.13+0.07,0.01,0.13,0.25]);
                
                h.ANN.datasets_list = uicontrol('Parent',data_panel,'Style','listbox','Units','Normalized','String',obj.DATA.DATA_SETS,'BackgroundColor','white','Max',20,'Min',2,'Callback',{@LoadFeatures},...
                    'Position',[0.03,0.25,0.3,0.7]);
                
                h.ANN.features_list = uicontrol('Parent',data_panel,'Style','listbox','Units','Normalized','BackgroundColor','white','Max',20,'Min',2,'Callback',{@SetFeatures},...
                    'Position',[0.07+0.28,0.02,0.62,0.95]);
                
                
                
                if obj.DATA.loading %Set the datasets when loading saved data
                    set(h.ANN.datasets_list,'Value',obj.DATA.DATA_SETS_SEL);
                    LoadFeatures(1, []);
                    set(h.ANN.delete_button, 'Enable', 'on');
                else
                    LoadStudyDatasets;
                end
                
                %Load datasets from xls files
                function OpenDataSet_Button(source,eventdata)
                    if(length(obj.DATA.PATHNAME)>1)
                        [ filename , pathname ] = uigetfile (  {'*.xls'} , 'Choose a xls dataset file','MultiSelect','on',obj.DATA.PATHNAME);
                    else
                        [ filename , pathname ] = uigetfile (  {'*.xls'} , 'Choose a xls dataset file','MultiSelect','on');
                    end
                    
                    current_path = pwd;
                    obj.DATA.PATHNAME = pathname(length(current_path)+2:end);
                    if isequal(filename,0)
                        disp('You must select a file!');
                    elseif ischar(filename)
                        [pathname filename];
                        obj.DATA.DATA_SETS_PATHS(obj.DATA.DATA_SETS_LAST_POS) = {[pathname filename]};
                        obj.DATA.DATA_SETS(obj.DATA.DATA_SETS_LAST_POS) = {filename};
                        obj.DATA.DATA_SETS_LAST_POS = obj.DATA.DATA_SETS_LAST_POS + 1;
                        
                        obj.DATA.DATA_SETS;
                        set(h.ANN.datasets_list,'String',obj.DATA.DATA_SETS);
                        set(h.ANN.datasets_list,'Value',obj.DATA.DATA_SETS_LAST_POS-1);
                        LoadFeatures([],[]);
                        
                        set(h.ANN.delete_button, 'Enable', 'on');
                    else
                        disp('FILENAMES:');
                        strcat(pathname,char(filename));
                        aux = obj.DATA.DATA_SETS_LAST_POS;
                        for i = 1:length(filename)
                            obj.DATA.DATA_SETS_PATHS(obj.DATA.DATA_SETS_LAST_POS) = {[pathname char(filename(i))]};
                            obj.DATA.DATA_SETS(obj.DATA.DATA_SETS_LAST_POS) = {char(filename(i))};
                            obj.DATA.DATA_SETS_LAST_POS = obj.DATA.DATA_SETS_LAST_POS + 1;
                        end
                        obj.DATA.DATA_SETS;
                        obj.DATA.DATA_SETS_PATHS;
                        set(h.ANN.datasets_list,'String',obj.DATA.DATA_SETS);
                        set(h.ANN.datasets_list,'Value',aux:obj.DATA.DATA_SETS_LAST_POS-1);
                        LoadFeatures([],[]);
                        
                        set(h.ANN.delete_button, 'Enable', 'on');
                    end
                    
                end
                
                %Delete datasets from the datasets list
                function Delete_Button(source, eventdata)
                    val=get(h.ANN.datasets_list,'Value');
                    str=get(h.ANN.datasets_list,'String');
                    for i=length(val):-1:1
                        obj.DATA.FEATURES_LIST(val(i)) = [];
                        obj.DATA.FEATURES(val(i)) = [];
                        
                        obj.DATA.DATA_SETS_PATHS(val(i)) = [];
                        obj.DATA.DATA_SETS(val(i)) = [];
                        obj.DATA.DATA_SETS_LAST_POS = obj.DATA.DATA_SETS_LAST_POS - 1;
                        
                        set(h.ANN.datasets_list, 'Value', []);
                        set(h.ANN.datasets_list, 'String', obj.DATA.DATA_SETS);
                        set(h.ANN.features_list, 'Value', []);
                        set(h.ANN.features_list, 'String', []);
                    end
                    
                    str=get(h.ANN.datasets_list,'String');
                    
                    if isempty(str)
                        set(h.ANN.delete_button, 'Enable', 'off');
                    end
                end
                
                %Load the features of datasets into the data object
                function LoadFeatures(source, eventdata)
                    val=get(h.ANN.datasets_list,'Value');
                    if ~isempty(val)
                        if isempty(source)
                            [num,txt] = xlsread(char(obj.DATA.DATA_SETS_PATHS(val(1))),'C1:P1');
                            set(h.ANN.features_list,'String',txt);
                            for i=1:length(val)
                                obj.DATA.FEATURES_LIST{val(i)} = txt;
                                obj.DATA.FEATURES{val(i)} = ones(1,length(txt));
                            end
                            set(h.ANN.features_list,'Value',1:length(txt));
                        else
                            a = obj.DATA.FEATURES{val(1)};
                            %b = obj.DATA.FEATURES_LIST{val(1)};
                            
                            h.list = obj.DATA.FEATURES_LIST;
                            h.feat = obj.DATA.FEATURES;
                            
                            set(h.ANN.features_list,'String',obj.DATA.FEATURES_LIST{val(1)});
                            set(h.ANN.features_list,'Value',find(a==1));
                        end
                        
                    end
                end
                
                %Update the features selected by the user in the data object
                function SetFeatures(source, eventdata)
                    
                    val=get(source,'Value');
                    str=get(source,'String');
                    pos=get(h.ANN.datasets_list,'Value');
                    
                    if ~isempty(val)
                        fea = zeros(1,length(str));
                        for i=1:length(val)
                            fea(val(i)) = 1;
                        end
                        
                        for i=1:length(pos) %TODO: Test these conditions
                            if length(obj.DATA.FEATURES{pos(i)}) == length(fea) %If the dest matrix is equal
                                obj.DATA.FEATURES{pos(i)} = fea;
                            elseif length(obj.DATA.FEATURES{pos(i)}) > length(fea) %If the dest matrix is bigger
                                aux = zeros(1,length(obj.DATA.FEATURES{pos(i)}));
                                aux(1:length(fea)) = fea;
                                obj.DATA.FEATURES{pos(i)} = aux;
                            else          %If the dest matrix is smaller
                                aux = fea(1,length(obj.DATA.FEATURES{pos(i)}));
                                obj.DATA.FEATURES{pos(i)} = aux;
                            end
                        end
                    end
                end
                
                %Fill the dataset list with results from the other modules
                function LoadStudyDatasets(source, eventdata)
                    %name: studyname.datasetname
                    %studyname: study.name
                    %datasetname: study.dataset(i).name
                    %features: study.dataset(i).name.features.*
                    %study.dataset(i).name.features.c_* (~isempty)
                    
                    %1� Insert the datasets to the list
                    ds_name = strcat(obj.STUDY.name,'.');
                    aux = obj.DATA.DATA_SETS_LAST_POS;
                    for i=1:length(obj.STUDY.dataset)
                        ds_name2 = strcat(ds_name,obj.STUDY.dataset(i).name);
                        h.DATA_SETS = obj.DATA.DATA_SETS;
                        h.ds_name2 = ds_name2;
                        
                        if isempty(obj.DATA.DATA_SETS)
                            obj.DATA.DATA_SETS(obj.DATA.DATA_SETS_LAST_POS) = {ds_name2};
                            
                            %Add position of dataset, useful for the train
                            %function to capture the right features, e.g.
                            %study1, study2, etc.
                            obj.DATA.DATA_SETS_PATHS(obj.DATA.DATA_SETS_LAST_POS) = {[obj.DATA.EPILAB_DS_FLAG num2str(i)]};
                            obj.DATA.DATA_SETS_LAST_POS = obj.DATA.DATA_SETS_LAST_POS + 1;
                            break;
                        end
                        
                        for j=1:length(obj.DATA.DATA_SETS)
                            if strcmp(obj.DATA.DATA_SETS{j}, ds_name2)
                                obj.DATA.DATA_SETS(j) = [];
                                obj.DATA.DATA_SETS_LAST_POS = obj.DATA.DATA_SETS_LAST_POS - 1;
                                aux = aux - 1; %Update auxiliar var
                                break;
                            end
                        end
                        
                        obj.DATA.DATA_SETS(obj.DATA.DATA_SETS_LAST_POS) = {ds_name2};
                        obj.DATA.DATA_SETS_PATHS(obj.DATA.DATA_SETS_LAST_POS) = {[obj.DATA.EPILAB_DS_FLAG num2str(i)]}; %Add reference to the paths data structure
                        obj.DATA.DATA_SETS_LAST_POS = obj.DATA.DATA_SETS_LAST_POS + 1;
                        
                    end
                    
                    
                    %2� Load features
                    for i=1:length(obj.STUDY.dataset) % 2.1 For each dataset
                        
                        types = fieldnames(obj.STUDY.dataset(i).results.featureExtractionMethods);
                        
                        final_matrix = {};
                        count = 1;
                        for j=length(types):-1:1  % 2.2 For each feature type
                            e = cell2mat(strcat('isempty(','obj.STUDY.dataset(i).results.featureExtractionMethods.',types(j),')'));
                            a = cell2mat(strcat('fieldnames(','obj.STUDY.dataset(i).results.featureExtractionMethods.',types(j),')'));
                            
                            if ~eval(e)
                                features = eval(a);
                                
                                for x=length(features):-1:1  % 2.3 For each feature
                                    feat = cell2mat(features(x));
                                    e2 = strcat(e(1:end-1),'.',feat,')');
                                    
                                    if or(eval(e2), feat(1:2) ~= obj.DATA.FEATURES_TAG)
                                        disp(feat)
                                        features(x) = [];
                                    end
                                end
                                f = features(1);
                                features=fieldnames(eval(cell2mat(strcat('obj.STUDY.dataset(i).results.featureExtractionMethods.',types(j),'.',f))));
                                for x=1:length(features)  % 2.4 Add new features to final matrix
                                    final_matrix(count) = strcat(types(j),'.',features(x));
                                    count = count + 1;
                                end
                                
                            end
                        end
                        
                        obj.DATA.FEATURES_LIST{aux} = final_matrix;
                        obj.DATA.FEATURES_LIST
                        obj.DATA.FEATURES{aux} = ones(1,length(final_matrix));
                        aux = aux + 1;
                        
                    end
                    
                    % 3� Apply changes to the handles
                    set(h.ANN.features_list,'String',{});
                    set(h.ANN.features_list,'String',{});
                    
                    set(h.ANN.datasets_list,'Value',[]);
                    set(h.ANN.datasets_list,'String',obj.DATA.DATA_SETS);
                    
                    set(h.ANN.delete_button, 'Enable', 'on');
                end
            end
            
            function drawPerfPanel(perf_panel)
                
                h.ANN.tab_res=uitable('parent',perf_panel,'Data',{},'ColumnName', {'Name','Layers','SS_AL','FPR','MIN_ANT','MAX_ANT','AVG_ANT','STD_ANT','SS','SP','AC','Rel','P-Ictal','Th.','TF'},'Units','Normalized',...
                    'RearrangeableColumn','on','Position',[0.01 0.01 0.98 0.99],'ColumnWidth','auto','CellSelectionCallback',@UpdateSelected);
                
                %               IPOS = 0.05;
                %               h.ANN.acc_text = uicontrol('Parent',perf_panel,'Style','text','Units','Normalized','String','AC = ','FontSize',10,...
                %                                'Position',[0.1,IPOS,0.55,0.3],'HorizontalAlignment','Left');
                %               IPOS = IPOS + 0.3;
                %               h.ANN.spec_text = uicontrol('Parent',perf_panel,'Style','text','Units','Normalized','String','SP = ','FontSize',10,...
                %                                'Position',[0.1,IPOS,0.55,0.3],'HorizontalAlignment','Left');
                %               IPOS = IPOS + 0.3;
                %               h.ANN.sens_text = uicontrol('Parent',perf_panel,'Style','text','Units','Normalized','String','SS = ','FontSize',10,...
                %                                'Position',[0.1,IPOS,0.55,0.3],'HorizontalAlignment','Left');
                %               %align([h.ANN.sens_text h.ANN.spec_text h.ANN.acc_text],'Left','None');
                %
                %               obj.DATA
                %
                %               if obj.DATA.loading
                updatePerformanceValues(obj);
                %end
            end
            
            function  UpdateSelected (source, event)
                h.ANN.res_cel_sel=event.Indices(:,1);
            end
            
            %            function drawPerfPanelAl(perf_panel)
            %
            %               IPOS = 0.05;
            %               h.ANN.sens_text_al = uicontrol('Parent',perf_panel,'Style','text','Units','Normalized','String','SS = ','FontSize',10,...
            %                                'Position',[0.1,IPOS,0.55,0.3],'HorizontalAlignment','Left');
            %               IPOS = IPOS + 0.3;
            %               h.ANN.fpr_text = uicontrol('Parent',perf_panel,'Style','text','Units','Normalized','String','FPR = ','FontSize',10,...
            %                                'Position',[0.1,IPOS,0.55,0.3],'HorizontalAlignment','Left');
            %               IPOS = IPOS + 0.3;
            %               h.ANN.rel = uicontrol('Parent',perf_panel,'Style','text','Units','Normalized','String','Rel. = ','FontSize',10,...
            %                                'Position',[0.1,IPOS,0.55,0.3],'HorizontalAlignment','Left');
            %               %align([h.ANN.sens_text h.ANN.spec_text
            %               %h.ANN.acc_text],'Left','None');
            %
            %               if obj.DATA.loading
            %                 updatePerformanceValuesAl(obj,obj.DATA.FPR,obj.DATA.SS_AL,obj.DATA.REL);
            %               end
            %            end
            %
            
            function npanel=create_netPanel(net,panel)
                % Set current data to the selected data set.
                % TODO: Analyse the memory of constantly creating
                % uipanels
                import PredictionAlgorithms.Artificial_Neural_Networks.Types.*;
                
                net=char(net);
                
                switch net
                    
                    case obj.DATA.NNET_LSTM %User selected the Probabilistic Network
                        obj.NNET = Artificial_Neural_Networks_LSTM(obj.DATA,obj);
                        npanel = obj.NNET.draw(panel);
                        
                    case obj.DATA.NNET_CFBP % User selected Cascade-forward backprop.
                        
                        obj.NNET = Artificial_Neural_Networks_CFBP(obj.DATA,obj);
                        npanel = obj.NNET.draw(panel);
                        
                    case obj.DATA.NNET_COMP     % User selected Competitive.
                        
                        obj.NNET = Artificial_Neural_Networks_COMP(obj.DATA,obj);
                        npanel = obj.NNET.draw(panel);
                        
                    case obj.DATA.NNET_FFBP     % User selected Feed-forward backprop.
                        
                        obj.NNET = Artificial_Neural_Networks_FFBP(obj.DATA,obj);
                        npanel = obj.NNET.draw(panel);
                        
                    case obj.DATA.NNET_ELMAN    % User selected Elman Backprop network
                        
                        obj.NNET = Artificial_Neural_Networks_ELMAN(obj.DATA,obj);
                        npanel = obj.NNET.draw(panel);
                        
                    case obj.DATA.NNET_RECURRENT  %User selected Layer Recurrent network
                        
                        obj.NNET = Artificial_Neural_Networks_RECURRENT(obj.DATA,obj);
                        npanel = obj.NNET.draw(panel);
                        
                    case obj.DATA.NNET_FFTD  %User selected Feed-forward Time-Delay network
                        
                        obj.NNET = Artificial_Neural_Networks_FFTD(obj.DATA,obj);
                        npanel = obj.NNET.draw(panel);
                        
                    case obj.DATA.NNET_DTD  %User selected Feed-forward Distributed Time-Delay network
                        
                        obj.NNET = Artificial_Neural_Networks_DTD(obj.DATA,obj);
                        npanel = obj.NNET.draw(panel);
                        
                    case obj.DATA.NNET_RBF  %User selected Radial Basis Function (exact fit)
                        
                        obj.NNET = Artificial_Neural_Networks_RBF(obj.DATA,obj);
                        npanel = obj.NNET.draw(panel);
                        
                    case obj.DATA.NNET_RBFF  %User selected Radial Basis Function (fewer neurons)
                        
                        obj.NNET = Artificial_Neural_Networks_RBFF(obj.DATA,obj);
                        npanel = obj.NNET.draw(panel);
                        
                    case obj.DATA.NNET_GENREG %User selected generalized regression neural network
                        
                        obj.NNET = Artificial_Neural_Networks_GENREG(obj.DATA,obj);
                        npanel = obj.NNET.draw(panel);
                        
                    case obj.DATA.NNET_LIND %User selected Linear Layer (design)
                        
                        obj.NNET = Artificial_Neural_Networks_LIND(obj.DATA,obj);
                        npanel = obj.NNET.draw(panel);
                        
                    case obj.DATA.NNET_LIN %User selected Linear Layer (train)
                        
                        obj.NNET = Artificial_Neural_Networks_LIN(obj.DATA,obj);
                        npanel = obj.NNET.draw(panel);
                        
                    case obj.DATA.NNET_LVQ %User selected Learning Vector Quantization
                        
                        obj.NNET = Artificial_Neural_Networks_LVQ(obj.DATA,obj);
                        npanel = obj.NNET.draw(panel);
                        
                    case obj.DATA.NNET_NARX %User selected Network with output and input feedback
                        
                        obj.NNET = Artificial_Neural_Networks_NARX(obj.DATA,obj);
                        npanel = obj.NNET.draw(panel);
                        
                    case obj.DATA.NNET_NARXSP %User selected Network with output and input feedback
                        
                        obj.NNET = Artificial_Neural_Networks_NARXSP(obj.DATA,obj);
                        npanel = obj.NNET.draw(panel);
                        
                    case obj.DATA.NNET_PERCEPTRON %User selected the Perceptron
                        
                        obj.NNET = Artificial_Neural_Networks_PERCEPTRON(obj.DATA,obj);
                        npanel = obj.NNET.draw(panel);
                        
                    case obj.DATA.NNET_PROBABILISTIC %User selected the Probabilistic Network
                        
                        obj.NNET = Artificial_Neural_Networks_PROBABILISTIC(obj.DATA,obj);
                        npanel = obj.NNET.draw(panel);
                        
                    case obj.DATA.NNET_SOM %User selected the Probabilistic Network
                        
                        obj.NNET = Artificial_Neural_Networks_SOM(obj.DATA,obj);
                        npanel = obj.NNET.draw(panel);
                        
                    
                end
                
                
                h.ANN.classes_text = uicontrol('Parent',npanel,'Style','text','Units','Normalized','String','Number of classes:','FontSize',10,...
                    'Position',[0.3+obj.DEFAULT_TEXT_WIDTH+obj.DEFAULT_SEPARATION*2+obj.DEFAULT_POPUP_WIDTH,1.2-0.2,obj.DEFAULT_TEXT_WIDTH/2,obj.DEFAULT_TEXT_HEIGHT*2],'HorizontalAlignment','Left');
                h.ANN.classes_popup = uicontrol('Parent',npanel,'Style','popup','Units','Normalized','String',obj.DATA.TARGET_CLASSES,'BackgroundColor','white','enable','on',...
                    'Position',[0.3+obj.DEFAULT_TEXT_WIDTH+obj.DEFAULT_SEPARATION*2+obj.DEFAULT_POPUP_WIDTH,1.2-0.30,obj.DEFAULT_TEXT_WIDTH/2,obj.DEFAULT_POPUP_HEIGHT],'HorizontalAlignment','Right');
                
                
                %Train type (list)
                h.ANN.train_type_text = uicontrol('Parent',npanel,'Style','text','Units','Normalized','String','Data Selection:',...
                    'Position',[0.05,0.23,0.2,0.1]);
                h.ANN.train_type_list = uicontrol('Parent',npanel,'Style','listbox','Units','Normalized','String',obj.DATA.TRAIN_TYPES,...
                    'Value',obj.DATA.TRAIN_TYPES_SEL,'BackgroundColor','white','Position',[0.04,0.05,0.3,0.2]);
                
                
%                 
%                 %Regularization subpanel
%                 h.ANN.reg_pop_text = uicontrol('Parent',npanel,'Style','text','Units','Normalized','String','Regularization method:','FontSize',10,...
%                     'Position',[0.3 + obj.DEFAULT_TEXT_WIDTH+obj.DEFAULT_SEPARATION*2+obj.DEFAULT_POPUP_WIDTH,1.15-0.6,obj.DEFAULT_TEXT_WIDTH/2,obj.DEFAULT_TEXT_HEIGHT*2],'HorizontalAlignment','Left');
%                 h.ANN.reg_popup = uicontrol('Parent',npanel,'Style','popup','Units','Normalized','String',obj.DATA.REG_OPTIONS,'BackgroundColor','white','enable','on',...
%                     'Position',[0.3 + obj.DEFAULT_TEXT_WIDTH+obj.DEFAULT_SEPARATION*2+obj.DEFAULT_POPUP_WIDTH,1.15-0.7,obj.DEFAULT_TEXT_WIDTH/3,obj.DEFAULT_TEXT_HEIGHT],'HorizontalAlignment','Right');
%                 
%                 h.ANN.reg_text = uicontrol('Parent',npanel,'Style','text','Units','Normalized','String','Threshold Level (%):',...
%                     'Position',[0.37,0.18,0.1,0.15]);
%                 h.ANN.reg_edit = uicontrol('Parent',npanel,'Style','edit','Units','Normalized','String',num2str(obj.DATA.firing_power_alarm*100),...
%                     'Position',[0.37,0.05,0.1,0.15]);
%                 
%                 set(h.ANN.reg_popup,'Callback',{@(src,event)RegPopupCallback(obj,src,event)} )
                
                
                

                %Alarm threshold level
                h.ANN.threshold_lev_text = uicontrol('Parent',npanel,'Style','text','Units','Normalized','String','Threshold Level (%):',...
                    'Position',[0.37,0.18,0.1,0.15]);

                h.ANN.threshold_lev_edit = uicontrol('Parent',npanel,'Style','edit','Units','Normalized','String',num2str(obj.DATA.firing_power_alarm*100),...
                    'Position',[0.37,0.05,0.1,0.15]);
                obj.th_lev_edit=h.ANN.threshold_lev_edit;
                
                %Classify Button
                h.ANN.classify_button = uicontrol('Parent',npanel,'Style','pushbutton','Units','Normalized','String','Classify','FontSize',10,'Callback',{@(src,event)Classify_Button(obj,src,event)},...
                    'Position',[0.51,0.005,0.1,0.2]);
                
                %Save Button
                h.ANN.save_button = uicontrol('Parent',npanel,'Style','pushbutton','Units','Normalized','String','Save','FontSize',10,'Enable','off','Callback',{@(src,event)Save_Button(obj,src,event)},...
                    'Position',[0.51+0.11,0.005,0.1,0.2]);
                
                %Plot results button
                h.ANN.plotResults_button = uicontrol('Parent',npanel,'Style','pushbutton','Units','Normalized','String','Plot results','FontSize',10,'Enable','off','Callback',{@(src,event)PlotResults_Button(obj,src,event)},...
                    'Position',[0.51+0.12+0.1,0.1,0.15,0.1]);
                
                h.ANN.PlotAlarm_button = uicontrol('Parent',npanel,'Style','pushbutton','Units','Normalized','String','Plot Alarms','FontSize',10,'Enable','off','Callback',{@(src,event)PlotAlarmResultsCallback(obj,src,event)},...
                    'Position',[0.51+0.12+0.1,0.005,0.15,0.1]);
                
                h.ANN.Eval_button = uicontrol('Parent',npanel,'Style','pushbutton','Units','Normalized','String','Evaluate','FontSize',10,'Enable','off','Callback',{@(src,event)EvaluateAlarmResultsCallback(obj,src,event)},...
                    'Position',[0.51+0.12+0.1+0.16,0.005,0.1,0.2]);
                
                if obj.DATA.loading %Enable PlotResults button if the ANN is being loaded
                    set(h.ANN.plotResults_button,'Enable','on');
                end
                
                
                if ~isempty(obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks)
                    set(h.ANN.plotResults_button,'Enable','on');
                    set(h.ANN.PlotAlarm_button,'Enable','on');
                    set(h.ANN.Eval_button,'Enable','on');
                end
                
                
%                 %Set Regularization method
%                 
%                 function RegPopupCallback(obj, source, evendata)
%                     
%                     switch (get(h.ANN.reg_popup,'value'))
%                         case 1 % Firing energy
%                             
%                             set(h.ANN.reg_text, 'String','Threshold Level:')
%                             set(h.ANN.reg_edit, 'String',num2str(obj.DATA.firing_power_alarm))
%                             
%                         case 2 % Kalman filter
%                             set(h.ANN.reg_text, 'String','kf design parameter:')
%                             set(h.ANN.reg_edit, 'String',num2str(obj.DATA.kalman_filter_par))
%                             
%                     end
%                     
%                 end
                
                
                
                %Classify the data
                function Classify_Button(obj, source,evendata)
                    obj.NNET.updateData();
                    s=get(h.ANN.train_type_list,'String');
                    
                    
                    act_lev=str2num(get(h.ANN.threshold_lev_edit,'String'))/100;
                    if act_lev>=0 && act_lev<=100
                        obj.DATA.firing_power_alarm=act_lev;
                    else
                        set(h.ANN.threshold_lev_edit,'String',num2str(obj.DATA.firing_power_alarm*100));
                    end
                    
%                     obj.DATA.REG_SELECTED = get(h.ANN.reg_popup, 'value');
%                     obj.DATA.reg_par = str2num(get(h.ANN.reg_edit,'String'));
                    
                    
                    obj.DATA.TARGET_SELECTED = get(h.ANN.classes_popup, 'Value');

                    
                    
                    obj.DATA.TRAIN_TYPES_SEL=get(h.ANN.train_type_list,'Value');
                    traint = s(obj.DATA.TRAIN_TYPES_SEL);
                    [SP SS AC obj.DATA.A obj.DATA.T2] = obj.FUNCTIONS.train(obj.NNET,traint);
                    
                    %Update classifier saveinfo
                    obj.DATA.saveinfo_datasets = length(get(h.ANN.datasets_list,'Value'));
                    val = get(h.ANN.datasets_list,'Value');
                    
                    obj.DATA.saveinfo_features = sum(obj.DATA.FEATURES{val(1)});
                    
                    val = get(h.ANN.train_type_list,'Value');
                    str = get(h.ANN.train_type_list,'String');
                    obj.DATA.saveinfo_other = str(val);
                    
                    
                    str = get(h.network_type_popup,'String');
                    val = get(h.network_type_popup,'Value');
                    obj.DATA.saveinfo_name = strcat(obj.panel_title,'.',str{val});
                    
                    %Update dataset selection
                    obj.DATA.DATA_SETS_SEL = get(h.ANN.datasets_list,'Value');
                    
                    
                    
                    
                    
                    
                    updatePerformanceValues(obj);
                    %updatePerformanceValuesAl(obj,obj.DATA.FPR,obj.DATA.SS_AL,obj.DATA.REL);
                    
                    
                    set(h.ANN.save_button, 'Enable' ,'on');
                    set(h.ANN.plotResults_button, 'Enable' ,'on');
                    set(h.ANN.PlotAlarm_button, 'Enable' ,'on');
                    set(h.ANN.Eval_button,'Enable','on');
                end
                
                %Save into the EpiLab data structure the classifier
                function Save_Button(obj, source, evendata)
                    
                    if exist('last_man_data_sets.mat')
                        dl=load('last_man_data_sets.mat');
                        
                        dat_train_time_start=dl.dat_train_time_start;
                        dat_train_time_end=dl.dat_train_time_end;
                        dat_test_time_start=dl.dat_test_time_start;
                        dat_test_time_end=dl.dat_test_time_end;
                        pictal_delta=dl.pictal_delta;
                        dat_train_time_start_idx=dl.dat_train_time_start_idx;
                        dat_train_time_end_idx=dl.dat_train_time_end_idx;
                        dat_test_time_start_idx=dl.dat_test_time_start_idx;
                        
                        dat_test_time_end_idx=dl.dat_test_time_end_idx;
                        
                        sel_feat=dl.sel_feat;
                        low_pass_stat=dl.low_pass_stat;
                        low_cut_off=dl.low_cut_off;
                        parameterAcq=dl.parameterAcq;
                        
                        
                        
                        
                        
                        c=clock();
                        
                        st=obj.DATA.STUDY.dataset.file.filename
                        idx=findstr(st,'.');
                        st=st(1:idx(1)-1);
                        save(fullfile('training_cache',[st,'_ann_',num2str(c(1)),'_',num2str(c(2)),...
                            '_',num2str(c(3)),'_',num2str(c(4)),'_',num2str(c(5)),'_',num2str(c(5)),'.mat']),'dat_train_time_start','dat_train_time_end','dat_test_time_start','dat_test_time_end','pictal_delta','dat_train_time_start_idx','dat_train_time_end_idx',...
                            'dat_test_time_start_idx','dat_test_time_end_idx','sel_feat','low_pass_stat','low_cut_off','parameterAcq');
                    end
                    
                    
                    import PredictionAlgorithms.Artificial_Neural_Networks.*;
                    
                    dest = Artificial_Neural_Networks_Data();
                    copyAllProperties(obj, obj.DATA,dest);
                    
                    if isempty(obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks) %TODO: Change the name (automatic way)
                        obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks = [dest];
                    else
                        pos=length(obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks);
                        obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks(pos+1) = dest;
                    end
                    
                    set(h.ANN.save_button, 'Enable' ,'off');
                    
                end
                
            end
            
            
            %            function EvaluateAlarmResultsCallback(obj, source, evendata)
            %
            %                projectFolder='seizureanalyzer';
            %                configFolder=[projectFolder '/config'];
            %                featureFolder=[projectFolder '/features'];
            %                condMkDir(configFolder);
            %                condMkDir(featureFolder);
            %
            %                feature={{'pso1'}};
            %                writeFeatureConfig([configFolder '/features.xml'],feature);
            %
            % %                writeProjectConfig(fileName,projectType,resultsPath,infoPath,filesPath,FPRmaxs,SOPs,ITs,
            % %                thresholds,
            % %                maximumBlockDistance,maximumGaps,timeAfterSeizure)
            %
            %                writeProjectConfig([configFolder '/project.xml'],'AlarmTesting','results/',
            %                   '.','features',9999,obj.DATA.model.('Pictal'),10,0,0,0,0);
            %
            %                 % FIND SEIZURES
            %                 seizures=[];
            %                 for f=1:length(study.dataset(study.dataset_selected).file)
            %                     events=study.dataset(study.dataset_selected).file(f).data.eeg_events;
            %                     events_number=length(events);
            %                     for i=1:events_number
            %                         if(strcmp(events(i).type,'<eeg-on>::="EEG-ON"'))
            %                             onset=events(i).started/study.dataset(study.dataset_selected).file(f).data.sampling_rate;
            %                             offset=events(i).started/study.dataset(study.dataset_selected).file(f).data.sampling_rate+60;
            %                             seizures=[seizures; onset offset];
            %                         end
            %                     end
            %                 end
            %
            %                 writePatientConfig([configFolder '/patients.xml'],1,{seizures},0,aux_time(end));
            %
            %            end
            
            
            
            
            function PlotAlarmResultsCallback(obj, source, evendata)
                if ~isempty(h.ANN.res_cel_sel)
                    ann_sel=h.ANN.res_cel_sel(1);
                    
                    figure('NumberTitle','off',...
                        'Name',['Alarm Results=ANN_' num2str(ann_sel) ', SS=' num2str(obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,ann_sel}.SS_AL)  ', FPR=' num2str(obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,ann_sel}.FPR)]);
                    
                    set(gcf, 'color',[0.95 0.97 0.99]);
                    
                    
                    act_al_lev=str2num(get(obj.th_lev_edit,'String'))/100;
                    
                    
                    
                    mod_al_lev=(obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,ann_sel}.Firing_pow);
                    
                    if (act_al_lev~=mod_al_lev) && act_al_lev>=0 && act_al_lev<=100
                        obj.DATA.firing_power_alarm=act_al_lev;
                        A=obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,ann_sel}.Out;
                        T2=obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,ann_sel}.Tar;
                        %A2=real2th(A',[obj.DATA.NORMAL_STATE obj.DATA.PRE_ICTAL_STATE obj.DATA.ICTAL_STATE obj.DATA.POS_ICTAL_STATE]);
                        
                        
                        [out,tint,time_out,tar]=class2alarm(obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,ann_sel}.Time,...
                            A,T2,obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,ann_sel}.Pictal,...
                            obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,ann_sel}.Pictal_state,obj.STUDY.dataset.results.parameterAcq,obj.DATA.firing_power_alarm);
                        [SS_AL,FPR,hours_estim,nseiz]=eval_results_alarm(out,tar);
                        
                        if SS_AL>0
                            time=time_out+obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,ann_sel}.Test_start;
                            evts=obj.DATA.STUDY.dataset.file(1).data.eeg_events;
                            [min_ant,max_ant,avg_ant,std_ant]=eval_ant_times(time,tar,out,...
                                obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,ann_sel}.Pictal,evts);
                        else
                            min_ant=NaN;
                            max_ant=NaN;
                            avg_ant=NaN;
                            std_ant=NaN;
                        end
                        
                        obj.DATA.MIN_ANT=min_ant;
                        obj.DATA.MAX_ANT=max_ant;
                        obj.DATA.AVG_ANT=avg_ant;
                        obj.DATA.STD_ANT=std_ant;
                        
                        obj.DATA.SS_AL=SS_AL;
                        obj.DATA.FPR=FPR;
                        obj.DATA.OUT_AL=out;
                        obj.DATA.TAR_AL=tar;
                        obj.DATA.TIME_AL=time_out;
                        
                        
                        up_mod=obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,ann_sel};
                        
                        up_mod.FPR=FPR;
                        up_mod.Firing_pow=act_al_lev;
                        up_mod.SS_AL=SS_AL;
                        up_mod.('Out_al')=out;
                        
                        
                        up_mod.MAX_ANT=obj.DATA.MAX_ANT;
                        up_mod.MIN_ANT=obj.DATA.MIN_ANT;
                        up_mod.AVG_ANT=obj.DATA.AVG_ANT;
                        up_mod.STD_ANT=obj.DATA.STD_ANT;
                        
                        ann_res=obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks;
                        
                        ann_res={ann_res{:},up_mod};
                        
                        obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks=ann_res;
                        
                        updatePerformanceValues(obj);
                        
                        set(gcf,'Name',['Alarm Results=ANN_' num2str(numel(ann_res)) ', SS=' num2str(up_mod.SS_AL)  ', FPR=' num2str(up_mod.FPR)]);
                        
                    else
                        
                        
                        
                        
                        
                        tar = obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,ann_sel}.Tar_al;
                        time_out=obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,ann_sel}.Time_al;
                        out=obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,ann_sel}.Out_al;
                        SS_AL=obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,ann_sel}.SS_AL;
                        FPR=obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,ann_sel}.FPR;
                        
                        %A2=real2th(A2,[obj.DATA.NORMAL_STATE obj.DATA.PRE_ICTAL_STATE obj.DATA.ICTAL_STATE obj.DATA.POS_ICTAL_STATE]);
                        
                        
                        
                        
                        
                    end
                    
                    time_out=time_out+obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,ann_sel}.Test_start;
                    
                    
                    
                    tm=time_out./3600;
                    
                    %Transforming Target in a series of seizure onsets
                    no_pict_idx=find(tar~=obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,ann_sel}.Pictal_state);
                    pict_idx=find(tar==obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,ann_sel}.Pictal_state);
                    tar(no_pict_idx)=0;
                    tar(pict_idx)=1;
                    
                    
                    dtar=diff(tar);
                    
                    idx_up=find(dtar==1);
                    idx_dn=find(dtar==-1);
                    
                    l_Group = hggroup;
                    
                    for p=1:numel(idx_up)
                        
                        rectangle('Position',[tm(idx_up(p)),0,tm(idx_dn(p))-tm(idx_up(p)),0.5],'Edgecolor','b','Facecolor','b')
                        
                        hl=line([tm(idx_dn(p)+1),tm(idx_dn(p)+1)],[0,1],'LineWidth',2,'color','k');
                        set(hl,'Parent',l_Group)
                        %leg=horzcat(leg,['Sz. ',num2str(p)])
                        
                        
                    end
                    hold on
                    stem(tm,(out)-0.2,'r','Marker','*','LineWidth',1)
                    
                    
                    
                    
                    
                    set(get(get(l_Group,'Annotation'),'LegendInformation'),...
                        'IconDisplayStyle','on');
                    
                    legend ('Onset Times','Raised Alarms');
                    title (['Alarm Results: SS=' num2str(SS_AL)  ', FPR (1/h)=' num2str(FPR)]);
                    xlabel ('Time(h)');
                    ylabel ('Prediction State')
                    axis([tm(1),tm(end),0,1])
                else
                    
                    warndlg('Please Select a model to plot!','Plot Model')
                    
                    
                end
                
            end
            
            
            %Plot the classifier results
            function PlotResults_Button(obj, source, evendata)
                
                %BEGIN - plot
                
                if ~isempty(h.ANN.res_cel_sel)
                    ann_sel=h.ANN.res_cel_sel(1);
                    figure('NumberTitle','off',...
                        'Name',['Prediction Results=ANN_' num2str(ann_sel) ', SS=' num2str(obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,ann_sel}.SS)  ', SP=' num2str(obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,ann_sel}.SP)  ', AC=' num2str(obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,ann_sel}.AC)]);
                    
                    set(gcf, 'color',[0.95 0.97 0.99]);
                    
                    A2 = obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,ann_sel}.Out;
                    A2=real2th(A2,[obj.DATA.NORMAL_STATE obj.DATA.PRE_ICTAL_STATE obj.DATA.ICTAL_STATE obj.DATA.POS_ICTAL_STATE]);
                    time=obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,ann_sel}.Time./3600;
                    
                    %make vectores the same size
                    m=size(time,2);
                    n=size(obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,ann_sel}.Tar,2);
                    dif = m-n;
                    time = time(dif+1:end);
                    size(time)
                    n
                    
                    plot (time,obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,ann_sel}.Tar,'-g'); hold on;
                    plot (time,A2,'--r');
                    
                    %                disp('plot')
                    %                size(A2)
                    %                size(obj.DATA.T2)
                    
                    %Plot seizure states
                    
                    plot (time,ones(1,length(A2))*obj.DATA.NORMAL_STATE,':','color', [0.8 0.8 0.8]);
                    plot (time,ones(1,length(A2))*obj.DATA.PRE_ICTAL_STATE,':','color', [0.6 0.6 0.6]);
                    plot (time,ones(1,length(A2))*obj.DATA.ICTAL_STATE,':','color', [0.4 0.4 0.4]);
                    plot (time,ones(1,length(A2))*obj.DATA.POS_ICTAL_STATE,':','color', [0.2 0.2 0.2]);
                    
                    legend ('Real data (target)', 'Prediction (classifier output)',...
                        ['Normal State (' num2str(obj.DATA.NORMAL_STATE) ')'],...
                        ['Pre-ictal State (' num2str(obj.DATA.PRE_ICTAL_STATE) ')'],...
                        ['Ictal State (' num2str(obj.DATA.ICTAL_STATE) ')'],...
                        ['Pos-Ictal State (' num2str(obj.DATA.POS_ICTAL_STATE) ')']);
                    
                    
                    title (['Prediction Results=ANN_' num2str(ann_sel) ', SS=' num2str(obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,ann_sel}.SS)  ', SP=' num2str(obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,ann_sel}.SP)  ', AC=' num2str(obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,ann_sel}.AC)]);
                    xlabel ('Time (h)');
                    ylabel ('Seizure state')
                    
                else
                    warndlg('Please Select a model to plot!','Plot Model')
                    
                end
                %END - plot
            end
            
            
            
            function EvaluateAlarmResultsCallback(obj, source, evendata)
                if ~isempty(h.ANN.res_cel_sel)
                    ann_sel=h.ANN.res_cel_sel(1);
                    
                    projectFolder='seizureanalyzer';
                    configFolder=[projectFolder '/config'];
                    featureFolder=[projectFolder '/features'];
                    condMkdir(configFolder);
                    condMkdir(featureFolder);
                    
                    feature={{'01'}};
                    writeFeatureConfigEpilab([configFolder '/features.xml'],feature);
                    
                    %                writeProjectConfig(fileName,projectType,resultsPath,infoPath,filesPath,FPRmaxs,SOPs,ITs,
                    %                thresholds,
                    %                maximumBlockDistance,maximumGaps,timeAfterSeizure)
                    
                    writeProjectConfigEpilab([configFolder '/project.xml'],'AlarmTesting','results/',...
                        '.','features','9999',num2str(obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,ann_sel}.Pictal),'10','0','0','0','0');
                    
                    % FIND SEIZURES
                    seizures=[];
                    for i=1:length(h.study.dataset.file(1).data.eeg_events)
                        if(strcmp(h.study.dataset.file(1).data.eeg_events(i).type,'seizure'))
                            onset=h.study.dataset.file(1).data.eeg_events(i).started;
                            offset=h.study.dataset.file(1).data.eeg_events(i).stopped;
                            seizures=[seizures; onset offset];
                        end
                    end
                    
                    writePatientConfigEpilab([configFolder '/patients.xml'],1,{seizures},...
                        int32(h.study.dataset.results.classifiers.Artificial_Neural_Networks{1,ann_sel}.Test_start),...
                        int32(h.study.dataset.results.classifiers.Artificial_Neural_Networks{1,ann_sel}.Test_stop));
                    
                    alarms=int32(obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,ann_sel}.Time_al(obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,ann_sel}.Out_al>0)+...
                        obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,ann_sel}.Test_start);
                    
                    condMkdir([configFolder '/../results/alarms/']);
                    fAlarms=fopen([configFolder '/../results/alarms/pat001.alarms'],'w');
                    fprintf(fAlarms,'01\t0.0000\t');
                    fprintf(fAlarms,'%u\t',alarms);
                    fclose(fAlarms);
                    
                    cd('seizureanalyzer')
                    if ispc
                        system('SeizureAnalyzer.exe config')
                    elseif isunix
                        system('./seizureanalyzer_linux config')
                    end
                    cd('..')
                    
                    [SPH, SOP, FPRmax, usedSeizures, prePostIctalTime, feature, threshold, corrects, ...
                        incorrects, FPR, sensitivity, correctsTimes, incorrectsTimes, correctDiffs, incorrectDiffs] = ...
                        textread('seizureanalyzer/results/pat001/epilab/parameters.txt', '%f %f %f %f %f %s %f %f %f %s %f %s %s %s %s', -1, 'bufsize', 8*4096);
                    
                    SPH=SPH;
                    
                    dim=str2double(inputdlg('Please enter the dimension of free parameters (e.g., the number of independent models tested)'));
                    fprintf('FPR: %f, SOP: %f, usedSeizures: %i, dim: %i, alpha: %f', str2double(FPR{1})/3600,SOP,usedSeizures,dim,0.05);
                    
                    sigLevel=calculateSigLevelEpilab(str2double(FPR{1})/3600,SOP,usedSeizures,dim,0.05);
                    
                    msg=['The sensitivity of the alarms of the classifier is ' num2str(sensitivity) ', the FPR is ' num2str(FPR{1}) '. The sensitivity of the random predictor is ' ...
                        num2str(sigLevel) ' for the chosen dimension of free parameters of ' num2str(dim) '. Hence, the result is'];
                    if(sensitivity>sigLevel+0.000001)
                        msg=[msg ' significant'];
                        obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,ann_sel}.REL='Sig.';
                    else
                        msg=[msg ' insignificant'];
                        obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,ann_sel}.REL='N. Sig.';
                    end
                    msg=[msg '. For this analysis, ' num2str(usedSeizures) ' seizures were analyzed. Goodbye.'];
                    msgbox(msg)
                    
                else
                    
                    warndlg('Please Select a model to Statisticaly Evaluate!','Statistical Validation')
                    
                    
                end
            end
            
            
            
            %
            %            function PlotAlarmResultsCallback(obj, source, evendata)
            %
            %
            %                figure('NumberTitle','off',...
            %                 'Name',['Prediction Results=' obj.DATA.saveinfo_name ', SS=' num2str(obj.DATA.SS)  ', SP=' num2str(obj.DATA.SP) ', AC=' num2str(obj.DATA.AC)]);
            %
            %                set(gcf, 'color',[0.95 0.97 0.99]);
            %
            %
            %                act_al_lev=str2num(get(obj.th_lev_edit,'String'))/100;
            %
            %
            %
            %
            %                if (act_al_lev~=obj.DATA.firing_power_alarm) && act_al_lev>=0 && act_al_lev<=100
            %                    obj.DATA.firing_power_alarm=act_al_lev;
            %                    A=obj.DATA.A;
            %                    T2=obj.DATA.T2;
            %                    A2=real2th(A',[obj.DATA.NORMAL_STATE obj.DATA.PRE_ICTAL_STATE obj.DATA.ICTAL_STATE obj.DATA.POS_ICTAL_STATE]);
            %
            %
            %
            %
            %
            %                [out,tint,time_out,tar]=class2alarm(obj.DATA.test_time_vec,A2,T2,obj.DATA.pictal_delta,obj.DATA.PRE_ICTAL_STATE,obj.DATA.pAcq,obj.DATA.firing_power_alarm);
            %                [SS_AL,FPR,hours_estim,nseiz]=eval_results_alarm(out,tar);
            %
            %
            %
            %                obj.DATA.SS_AL=SS_AL;
            %                obj.DATA.FPR=FPR;
            %                obj.DATA.TIME_AL=time_out;
            %                obj.DATA.OUT_AL=out;
            %                obj.DATA.TAR_AL=tar;
            %
            %                up_mod=obj.DATA.model;
            %
            %                   up_mod.FPR=FPR;
            %                   up_mod.Firing_pow=act_al_lev;
            %                   up_mod.SS_AL=SS_AL;
            %                   up_mod.('Out_al')=out;
            %
            %                   ann_res=obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks;
            %
            %                    ann_res={ann_res{:},up_mod};
            %
            %                    obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks=ann_res;
            %
            %
            %
            %                updatePerformanceValuesAl(obj,obj.DATA.FPR,obj.DATA.SS_AL,obj.DATA.REL);
            %
            %                else
            %
            %
            %
            %
            %                tar=obj.DATA.TAR_AL;
            %                time_out=obj.DATA.TIME_AL;
            %                out=obj.DATA.OUT_AL;
            %
            %                SS_AL=obj.DATA.SS_AL;
            %                FPR=obj.DATA.FPR;
            %                end
            %
            %                %Transforming Target in a series of seizure onsets
            %                 no_pict_idx=find(tar~=obj.DATA.PRE_ICTAL_STATE);
            %                 pict_idx=find(tar==obj.DATA.PRE_ICTAL_STATE);
            %                 tar(no_pict_idx)=0;
            %                 tar(pict_idx)=1;
            %
            %                 %ntar=zeros(1,size(time_out,2));
            %                 %tal=find(diff(tar)==-1)+2;%The one is to accont for the early detection stare
            %                %ntar(tal)=2;
            %
            %                size(time_out)
            %                size(out)
            %
            %                stem (time_out./3600,out,'r'); hold on;
            %                plot (time_out./3600,tar,'--k');
            %
            %
            %
            %                legend ('Raised Alarms', 'Pre-Ictal period');
            %                title (['Prediction Results: SS=' num2str(SS_AL)  ', FPR (1/h)=' num2str(FPR)]);
            %                xlabel ('Time(h)');
            %                ylabel ('Prediction State')
            %            %END - plot
            %
            %
            %
            %
            %
            %               end
            
            
            
            function updatePerformanceValues(obj)
                
                
                n_ann=numel(obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks);
                
                tab_ann=cell(n_ann,10);
                for an=1:n_ann
                    
                    tst=[];
                    for j=1:size(obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,an}.Transfer_Functions,2)
                        tst=[tst,obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,an}.Transfer_Functions{j},' '];
                    end
                    
                    
                    tab_ann{an,1}=['ANN_',num2str(an)];
                    tab_ann{an,2}=num2str(obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,an}.Layers);
                    tab_ann{an,3}=num2str(obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,an}.SS_AL);
                    tab_ann{an,4}=num2str(obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,an}.FPR);
                    
                    
                    tab_ann{an,5}=num2str(obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,an}.MIN_ANT);
                    tab_ann{an,6}=num2str(obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,an}.MAX_ANT);
                    tab_ann{an,7}=num2str(obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,an}.AVG_ANT);
                    tab_ann{an,8}=num2str(obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,an}.STD_ANT);
                    
                    
                    tab_ann{an,9}=num2str(obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,an}.SS);
                    tab_ann{an,10}=num2str(obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,an}.SP);
                    tab_ann{an,11}=num2str(obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,an}.AC);
                    tab_ann{an,12}=num2str(obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,an}.REL);
                    tab_ann{an,13}=num2str(obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,an}.Pictal/60);
                    tab_ann{an,14}=num2str(obj.STUDY.dataset.results.classifiers.Artificial_Neural_Networks{1,an}.Firing_pow*100);
                    tab_ann{an,15}=tst;
                    
                    
                    
                    
                end
                set(h.ANN.tab_res,'Data',tab_ann);
                
                
                
                %               obj.DATA.SP = SP; obj.DATA.SS = SS; obj.DATA.AC = AC;
                %
                %               set(h.ANN.sens_text,'String', sprintf('SS = %.2f',SS));
                %               set(h.ANN.spec_text,'String', sprintf('SP = %.2f',SP));
                %               set(h.ANN.acc_text,'String',  sprintf('AC = %.2f',AC));
            end
            
            
            %            function updatePerformanceValuesAl(obj,FPR,SS,Rel)
            %
            %               obj.DATA.FPR = FPR; obj.DATA.SS_AL = SS; obj.DATA.REL = Rel;
            %
            %               set(h.ANN.sens_text_al,'String', sprintf('SS = %.2f',SS));
            %               set(h.ANN.fpr_text,'String', sprintf('FPR = %.2f',FPR));
            %               set(h.ANN.rel,'String',  sprintf('Rel = %.2f',Rel));
            %            end
            
            
            
            
            
        end
        
        %Clear the content of the sub-module panel
        %This function is called by the module when the user want to change to another sub-module
        %This is important to avoid memory problems
        %REQUIRED FUNCTION
        function clear(obj)
            %TODO...
        end
        
        % Update the number of layers
        function layersDefinition_Callback(obj, source,eventdata)
            
            global h;
            
            str = eval(get(source, 'String'));
            obj.DATA.NUMBER_LAYERS = str;
            la = {};
            k=1
            
            obj.DATA.layers=[];
            for nl=1:numel(str)
                
                
                for i = 1:obj.DATA.NUMBER_LAYERS(nl)
                    la(k) = {['Net' num2str(nl) ' Layer ' num2str(i)]};
                    k=k+1;
                end
                
                lvec=[];
                
                for i = 1:obj.DATA.NUMBER_LAYERS(nl)
                    
                    lvec.(['layer',num2str(i)])=struct('neu',15,'actf',1);
                    
                    if strcmp(obj.NNET, obj.DATA.NNET_DTD)
                        obj.DATA.DELAY_VECTOR(i) = {[]};
                    end
                end
                
                obj.DATA.layers.(['net',num2str(nl)])=lvec;
                
            end
            str
            la
            
            set(h.ANN.layer_x_popup,'Value',1);
            set(h.ANN.layer_x_popup,'String',la);
        end
        
        % Update the content of layer panel
        function layerSelection_Callback(obj, source, eventdata)
            
            global h;
            
            val = get(source, 'Value');
            strs=get(source,'string');
            
            str=strs{val};
            
            idx1=findstr(str,'Net');
            idx2=findstr(str,' Layer');
            net_num=str2num(str(idx1+3:idx2-1));
            idx2=findstr(str,' ');
            lay_num=str2num(str(idx2(end)+1:end))
            
            
            %for nl=1:numel(obj.DATA.NUMBER_LAYERS)
            if lay_num == obj.DATA.NUMBER_LAYERS(net_num)
                set(h.ANN.number_neurons_edit,'Enable','off');
                set(h.ANN.number_neurons_edit,'String','') %Correct number of neurons
                set(h.ANN.transfer_function_popup,'Value',obj.DATA.layers.(['net',num2str(net_num)]).(['layer',num2str(lay_num)]).actf); %Correct transfer function
            else
                set(h.ANN.number_neurons_edit,'Enable','on');
                stt=['[',sprintf('%d ',obj.DATA.layers.(['net',num2str(net_num)]).(['layer',num2str(lay_num)]).neu(:))];
                stt=[stt(1:end-1),']'];
                set(h.ANN.number_neurons_edit,'String',stt) %Correct number of neurons
                set(h.ANN.transfer_function_popup,'Value',obj.DATA.layers.(['net',num2str(net_num)]).(['layer',num2str(lay_num)]).actf) %Correct transfer function
            end
            
            if strcmp(obj.NNET, obj.DATA.NNET_DTD)
                set(h.ANN.delay_vector_edit, 'String', mat2str(cell2mat(obj.DATA.DELAY_VECTOR(val))));
            end
            %end
        end
        
        % Update the data related with the network layers
        function layerX_Callback(obj, source,eventdata)
            global h;
            
            pos = get(h.ANN.layer_x_popup, 'Value');
            
            
            strs=get(h.ANN.layer_x_popup,'string');
            
            str=strs{pos};
            
            idx1=findstr(str,'Net');
            idx2=findstr(str,' Layer');
            net_num=str2num(str(idx1+3:idx2-1));
            idx2=findstr(str,' ');
            lay_num=str2num(str(idx2(end)+1:end))
            
            neurons = eval(get(h.ANN.number_neurons_edit, 'String'));
            tfunction = get(h.ANN.transfer_function_popup, 'Value');
            
            if(lay_num ~= obj.DATA.NUMBER_LAYERS(net_num))
                obj.DATA.layers.(['net',num2str(net_num)]).(['layer',num2str(lay_num)]).neu= neurons; %Neurons
            end
            
            obj.DATA.layers.(['net',num2str(net_num)]).(['layer',num2str(lay_num)]).actf = tfunction; %Transfer_Function
        end
        
        function layerSelection_Callback_LSTM(obj, source, eventdata)
            
            global h;
            
            val = get(source, 'Value');
            strs=get(source,'string');
            
            str=strs{val};
            
            idx1=findstr(str,'Net');
            idx2=findstr(str,' Layer');
            net_num=str2num(str(idx1+3:idx2-1));
            idx2=findstr(str,' ');
            lay_num=str2num(str(idx2(end)+1:end))
            
            

            set(h.ANN.number_neurons_edit,'Enable','on');
            stt=['[',sprintf('%d ',obj.DATA.layers.(['net',num2str(net_num)]).(['layer',num2str(lay_num)]).neu(:))];
            stt=[stt(1:end-1),']'];
            set(h.ANN.number_neurons_edit,'String',stt) %Correct number of neurons

            
            if strcmp(obj.NNET, obj.DATA.NNET_DTD)
                set(h.ANN.delay_vector_edit, 'String', mat2str(cell2mat(obj.DATA.DELAY_VECTOR(val))));
            end
            %end
        end
         function layerX_Callback_LSTM(obj, source,eventdata)
            global h;
            
            pos = get(h.ANN.layer_x_popup, 'Value');
            
            
            strs=get(h.ANN.layer_x_popup,'string');
            
            str=strs{pos};
            
            idx1=findstr(str,'Net');
            idx2=findstr(str,' Layer');
            net_num=str2num(str(idx1+3:idx2-1));
            idx2=findstr(str,' ');
            lay_num=str2num(str(idx2(end)+1:end))
            
            neurons = eval(get(h.ANN.number_neurons_edit, 'String'));
            
            obj.DATA.layers.(['net',num2str(net_num)]).(['layer',num2str(lay_num)]).neu= neurons; %Neurons
            
            
        end       
        %Plot the classifier results
        
        
        
        
        %       function PlotResults_Button(obj, source, evendata)
        %
        %            %BEGIN - plot
        %                figure('NumberTitle','off',...
        %                 'Name',['Prediction Results=' obj.DATA.saveinfo_name ', SS=' num2str(obj.DATA.SS)  ', SP=' num2str(obj.DATA.SP) ', AC=' num2str(obj.DATA.AC)]);
        %
        %                set(gcf, 'color',[0.95 0.97 0.99]);
        %
        %                A2 = zeros(length(obj.DATA.T2),1);
        %                for i=1:length(obj.DATA.T2) % Convert the A into a 1,2,3,4 format
        %                     aux=max(obj.DATA.A(:,i));
        %                     A2(i) = find(obj.DATA.A(:,i)==max(obj.DATA.A(:,i)));
        %
        %                     if(aux > 0) %Allow a more detailed plot
        %                       A2(i) = A2(i) + (aux-1);
        %                     else
        %                       A2(i) = A2(i) + (aux+1);
        %                     end
        %                end
        %
        %                length(obj.DATA.T2)
        %                length(A2)
        %                A2=real2th(A2,[obj.DATA.NORMAL_STATE obj.DATA.PRE_ICTAL_STATE obj.DATA.ICTAL_STATE obj.DATA.POS_ICTAL_STATE]);
        %
        %                plot ([1:length(obj.DATA.T2)].*obj.DATA.STUDY.dataset.results.parameterAcq./3600,obj.DATA.T2,'-g'); hold on;
        %                plot ([1:length(A2)].*obj.DATA.STUDY.dataset.results.parameterAcq./3600,A2,'--r');
        %                %Plot seizure states
        %                plot ([1:length(A2)].*obj.DATA.STUDY.dataset.results.parameterAcq./3600,ones(1,length(A2))*obj.DATA.NORMAL_STATE,':','color', [0.8 0.8 0.8]);
        %                plot ([1:length(A2)].*obj.DATA.STUDY.dataset.results.parameterAcq./3600,ones(1,length(A2))*obj.DATA.PRE_ICTAL_STATE,':','color', [0.6 0.6 0.6]);
        %                plot ([1:length(A2)].*obj.DATA.STUDY.dataset.results.parameterAcq./3600,ones(1,length(A2))*obj.DATA.ICTAL_STATE,':','color', [0.4 0.4 0.4]);
        %                plot ([1:length(A2)].*obj.DATA.STUDY.dataset.results.parameterAcq./3600,ones(1,length(A2))*obj.DATA.POS_ICTAL_STATE,':','color', [0.2 0.2 0.2]);
        %
        %                legend ('Real data (target)', 'Prediction (classifier output)',...
        %                    ['Normal State (' num2str(obj.DATA.NORMAL_STATE) ')'],...
        %                    ['Pre-ictal State (' num2str(obj.DATA.PRE_ICTAL_STATE) ')'],...
        %                    ['Ictal State (' num2str(obj.DATA.ICTAL_STATE) ')'],...
        %                    ['Pos-Ictal State (' num2str(obj.DATA.POS_ICTAL_STATE) ')']);
        %                title (['Prediction Results=' obj.DATA.saveinfo_name ', SS=' num2str(obj.DATA.SS)  ', SP=' num2str(obj.DATA.SP) ', AC=' num2str(obj.DATA.AC)]);
        %                xlabel ('Data');
        %                ylabel ('Seizure state')
        %            %END - plot
        %       end
        
        %Method that copies all the properties from the src object to the dest obj
        %Useful to store the results in study data structure
        function copyAllProperties(obj, src, dest)
            
            
            prop = fieldnames(src);
            for i=1:length(prop)
                if ~strcmp(prop{i},'STUDY')
                    eval(strcat('dest.',prop{i},'=src.',prop{i},';'));
                end
            end
        end
        
        
        function writeFeatureConfig(fileName,features)
            
            fid=fopen(fileName,'w');
            
            fprintf(fid,['<?xml version="1.0"?>\n' ...
                '<DataSources>\n' ...
                '   <DataSource type="epilab" name="Epilab feature" minValue="-1000000.0" maxValue="1000000">\n\n']);
            
            for i=1:length(features)
                fprintf(fid,['    <Feature columnsBefore="0" columnsAfter="0">\n' ...
                    '      <FileExtension>%s.txt</FileExtension>\n' ...
                    '      <Abbreviation>%s</Abbreviation>\n' ...
                    '    </Feature>\n'],features{i}{1},features{i}{1});
            end
            
            fprintf(fid,'    </DataSource>\n\n</DataSources>\n');
            fclose(fid);
        end
        
        
        function writeProjectConfig(fileName,projectType,resultsPath,infoPath,filesPath,FPRmaxs,SOPs,ITs,thresholds,maximumBlockDistance,maximumGaps,timeAfterSeizure)
            
            fid=fopen(fileName,'w');
            
            fprintf(fid,['<?xml version="1.0"?>\n' ...
                '<Project type="%s"\n' ...
                '         maximumBlockDistance="%s" maximumGap="%s" maximumBlockLength="40h"\n' ...
                '         timeBeforeSeizure="-1" timeAfterSeizure="%s"\n' ...
                '         saveExhaustiveResults="0">\n' ...
                '\n' ...
                '  <ResultsPath>%s</ResultsPath>\n' ...
                '  <InfoPath>%s</InfoPath>\n' ...
                '\n' ...
                '  <DataSources>\n' ...
                '    <DataSource type="epilab" name="Epilab Feature">\n' ...
                '      <FilesPath>%s</FilesPath>\n' ...
                '      <Thresholds direction="negative" stayAboveBelowTime="1s">\n' ...
                '        %s\n' ...
                '      </Thresholds>\n' ...
                '    </DataSource>\n' ...
                '  </DataSources>\n' ...
                '\n' ...
                '  <DataProcessors>\n' ...
                '    <DataProcessor name="MedianSmoother">\n' ...
                '      <Parameter name="windowLength">1s</Parameter>\n' ...
                '      <Parameter name="writeToFile">false</Parameter>\n' ...
                '    </DataProcessor>\n' ...
                '  </DataProcessors>\n' ...
                '\n' ...
                '  <FPRmaxs>%s</FPRmaxs>\n' ...
                '  <SOPs>%s</SOPs>\n' ...
                '  <SPHs>%s</SPHs>\n' ...
                '\n' ...
                '</Project>\n' ...
                '\n'],projectType,maximumBlockDistance,maximumGaps,timeAfterSeizure, ...
                resultsPath,infoPath,filesPath,thresholds,FPRmaxs,SOPs,ITs);
            
            fclose(fid);
        end
        
        function writePatientConfig(fileName,nos,szs,startTime,endTime)
            
            fid=fopen(fileName,'w');
            
            fprintf(fid,['<?xml version="1.0"?>\n' ...
                '<Patients>\n\n']);
            
            for p=1:length(nos)
                sz=szs{p};
                
                fprintf(fid,['<Patient number="%03i">\n' ...
                    '    <Subfolder>.</Subfolder>\n' ...
                    '    <ResultsSubfolder>pat%%PatNr%%</ResultsSubfolder>\n\n' ...
                    '    <FeatureFiles type="wildcard">*%%FeatureFileExtension%%</FeatureFiles>\n' ...
                    '    <IncludePeriods>\n' ...
                    '      <Periods format="timeStamps" startOffset="0" endOffset="0">\n' ...
                    '        <Period><Start>%i</Start><End>%i</End></Period>\n' ...
                    '      </Periods>\n' ...
                    '    </IncludePeriods>\n\n' ...
                    '    <ExcludePeriods>\n' ...
                    '    </ExcludePeriods>\n'],nos(p),startTime,endTime);%,names{p});
                %             '      <Periods format="timeStampsFile" startOffset="0" endOffset="0">%%InfoPath%%/datenluecken/pat%s.exclude</Periods>\n' ...
                
                fprintf(fid,'    <RealSeizurePeriods>\n      <Periods format="timeStamps" startOffset="0" endOffset="0">\n');
                
                for j=1:size(sz,1)
                    fprintf(fid,'        <Period><Start>%i</Start><End>%i</End></Period>\n',int32(sz(j,1)),int32(sz(j,2)));
                end
                fprintf(fid,'      </Periods>\n    </RealSeizurePeriods>\n\n');
                fprintf(fid,'  </Patient>\n');
                
            end
            
            fprintf(fid,'\n\n</Patients>\n');
            
            fclose(fid);
        end
        
        
        function condMkdir(dir)
            if(~exist(dir,'dir'))
                mkdir(dir)
            end
        end
    end
    
end