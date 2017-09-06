%Defines the main class and interface of classifiers
classdef Artificial_Neural_Networks_LSTM < handle
   % The following properties can be set only by class methods
   properties
       INTERFACE;
       DATA;
   end
    
   methods
      %Constructor
      function NN = Artificial_Neural_Networks_LSTM(d,UI)
        NN.INTERFACE = UI;
        NN.DATA = d;
      end
      
      function npanel=draw(obj,fpanel)
           global h;           
           
%            npanel = uipanel('Parent',fpanel,'BorderType','none','BorderWidth',0,'Units','Normalized','Visible','on','Position',[obj.INTERFACE.NNET_PANEL_X,obj.INTERFACE.NNET_PANEL_Y,obj.INTERFACE.NNET_PANEL_WIDTH,obj.INTERFACE.NNET_PANEL_HEIGHT]);
% 
%            IPOS = 0.15;
%            %NOTE: The uicontrols are drawn in a
%            %bottom-up fashion
% 
%            IPOS = IPOS + 0.2;
% 
%            layers_panel_size = 0.4;
%            layers_panel = uipanel('Parent',npanel,'Title','Properties for: ','Units','Normalized','FontSize',10,...
%                'Position',[0,IPOS,0.8,layers_panel_size]);
% 
%            IPOS2 = 0.2;


           npanel = uipanel('Parent',fpanel,'Units','Normalized','Visible','on','Position',[obj.INTERFACE.NNET_PANEL_X,obj.INTERFACE.NNET_PANEL_Y,obj.INTERFACE.NNET_PANEL_WIDTH,0.8]);

           IPOS = 0.3;
           %NOTE: The uicontrols are drawn in a
           %bottom-up fashion

           IPOS = IPOS + 0.1;

           layers_panel_size = 0.3;
           layers_panel = uipanel('Parent',npanel,'Title','Properties for: ','Units','Normalized','FontSize',10,...
               'Position',[0,IPOS,0.8,layers_panel_size]);

           IPOS2 = 0;
           
           height = 0.05;
           width = 0.03;
           d = 0.1;
           
           %BEGIN: layers_panel
           
           
                IPOS2 = IPOS2 + obj.INTERFACE.DEFAULT_POPUP_HEIGHT/layers_panel_size;

                h.ANN.number_neurons_text = uicontrol('Parent',layers_panel,'Style','text','Units','Normalized','String','Number of Neurons:','FontSize',10,...
                   'Position',[0,IPOS2,obj.INTERFACE.DEFAULT_TEXT_WIDTH,obj.INTERFACE.DEFAULT_TEXT_HEIGHT/layers_panel_size]);
                h.ANN.number_neurons_edit = uicontrol('Parent',layers_panel,'Style','edit','Units','Normalized','String','15','BackgroundColor','white','Callback',{@(src,event)obj.INTERFACE.layerX_Callback_LSTM(src,event)},...
                   'Position',[obj.INTERFACE.DEFAULT_TEXT_WIDTH+obj.INTERFACE.DEFAULT_SEPARATION,IPOS2,obj.INTERFACE.DEFAULT_EDIT_WIDTH,obj.INTERFACE.DEFAULT_EDIT_HEIGHT/layers_panel_size]);                                

               IPOS2 = IPOS2 + obj.INTERFACE.DEFAULT_EDIT_HEIGHT/layers_panel_size ;

               h.ANN.layer_x_popup = uicontrol('Parent',layers_panel,'Style','popupmenu','Units','Normalized','String',{'Net 1 Layer 1','Net 1 Layer 2'},'BackgroundColor','white','Callback',{@(src,event)obj.INTERFACE.layerSelection_Callback_LSTM(src,event)},...
                'Position',[obj.INTERFACE.DEFAULT_TEXT_WIDTH+obj.INTERFACE.DEFAULT_SEPARATION,IPOS2,obj.INTERFACE.DEFAULT_POPUP_WIDTH,obj.INTERFACE.DEFAULT_POPUP_HEIGHT/layers_panel_size]);
           %END: layers_panel

           IPOS = IPOS + layers_panel_size+0.05;

           h.ANN.number_layers_text = uicontrol('Parent',npanel,'Style','text','Units','Normalized','String','Number of Layers:','FontSize',10,...
               'Position',[-0.1,IPOS,obj.INTERFACE.DEFAULT_TEXT_WIDTH,0.05]);
           h.ANN.number_layers_edit = uicontrol('Parent',npanel,'Style','edit','Units','Normalized','String',num2str(obj.DATA.NUMBER_LAYERS),'BackgroundColor','white','Callback',{@(src,event)obj.INTERFACE.layersDefinition_Callback(src,event)},...
               'Position',[0.12,IPOS,width,0.05]); 

          h.ANN.dropout_text = uicontrol('Parent',npanel,'Style','text','Units','Normalized','String',sprintf('Dropout:'),'FontSize',10,...
               'Position',[0.3,IPOS-0.05,obj.INTERFACE.DEFAULT_TEXT_WIDTH,height+0.05],'HorizontalAlignment','Left');
           h.ANN.dropout_edit = uicontrol('Parent',npanel,'Style','edit','Units','Normalized','String','0.6','BackgroundColor','white',...
               'Position',[0.38 ,IPOS,width,height]);
           
           
           h.ANN.early_detect_text = uicontrol('Parent',npanel,'Style','text','Units','Normalized','String',sprintf('Early Detection\nTime (s):'),'FontSize',10,...
               'Position',[obj.INTERFACE.DEFAULT_TEXT_WIDTH+obj.INTERFACE.DEFAULT_SEPARATION*2+obj.INTERFACE.DEFAULT_POPUP_WIDTH,IPOS-0.05,obj.INTERFACE.DEFAULT_TEXT_WIDTH,height+0.05],'HorizontalAlignment','Left');
           h.ANN.early_detect_edit = uicontrol('Parent',npanel,'Style','edit','Units','Normalized','String',num2str(obj.DATA.EARLY_DETECT_TIME),'BackgroundColor','white',...
               'Position',[obj.INTERFACE.DEFAULT_TEXT_WIDTH+obj.INTERFACE.DEFAULT_SEPARATION+obj.INTERFACE.DEFAULT_POPUP_WIDTH+obj.INTERFACE.DEFAULT_TEXT_WIDTH/2+obj.INTERFACE.DEFAULT_SEPARATION,IPOS,width,height]);
           
           
           obj.INTERFACE.layersDefinition_Callback(h.ANN.number_layers_edit,[]);

           IPOS = IPOS + d;
           
           %sequence length
           h.ANN.seq_text = uicontrol('Parent',npanel,'Style','text','Units','Normalized','String','Sequence length:','FontSize',10,...
               'Position',[-0.1,IPOS,obj.INTERFACE.DEFAULT_TEXT_WIDTH,height]);
           h.ANN.seq_edit = uicontrol('Parent',npanel,'Style','edit','Units','Normalized','String','50','BackgroundColor','white',...
               'Position',[0.12,IPOS,width,height]);
           
          h.ANN.reg_text = uicontrol('Parent',npanel,'Style','text','Units','Normalized','String',sprintf('Regularization:'),'FontSize',10,...
               'Position',[0.3,IPOS-0.05,obj.INTERFACE.DEFAULT_TEXT_WIDTH,height+0.05],'HorizontalAlignment','Left');
           h.ANN.reg_edit = uicontrol('Parent',npanel,'Style','edit','Units','Normalized','String','0.1','BackgroundColor','white',...
               'Position',[0.38,IPOS,width,height]);
        
           %PICTAL
           h.ANN.pictal_text = uicontrol('Parent',npanel,'Style','text','Units','Normalized','String','Pre-Ictal:','FontSize',10,...
               'Position',[obj.INTERFACE.DEFAULT_TEXT_WIDTH+obj.INTERFACE.DEFAULT_SEPARATION*2+obj.INTERFACE.DEFAULT_POPUP_WIDTH,IPOS,obj.INTERFACE.DEFAULT_TEXT_WIDTH,height],'HorizontalAlignment','Left');
           h.ANN.pictal_edit = uicontrol('Parent',npanel,'Style','edit','Units','Normalized','String',num2str(obj.DATA.PRE_ICTAL_TIME/60),'BackgroundColor','white',...
               'Position',[obj.INTERFACE.DEFAULT_TEXT_WIDTH+obj.INTERFACE.DEFAULT_SEPARATION+obj.INTERFACE.DEFAULT_POPUP_WIDTH+obj.INTERFACE.DEFAULT_TEXT_WIDTH/2+obj.INTERFACE.DEFAULT_SEPARATION,IPOS,width,height]);
           
           IPOS = IPOS + d;
 
           h.ANN.train_function_text = uicontrol('Parent',npanel,'Style','text','Units','Normalized','String','Optimizer:','FontSize',10,...
               'Position',[-0.1,IPOS,obj.INTERFACE.DEFAULT_TEXT_WIDTH,height]);
           h.ANN.train_function_popup = uicontrol('Parent',npanel,'Style','popupmenu','Units','Normalized','String',obj.DATA.TRAINING_FUNCTIONS_LSTM,'BackgroundColor','white',...
               'Position',[0.12,IPOS,0.07,height]);
           
          h.ANN.lr_text = uicontrol('Parent',npanel,'Style','text','Units','Normalized','String',sprintf('Learning rate:'),'FontSize',10,...
               'Position',[0.3,IPOS-0.05,obj.INTERFACE.DEFAULT_TEXT_WIDTH,height+0.05],'HorizontalAlignment','Left');
           
           h.ANN.lr_edit = uicontrol('Parent',npanel,'Style','edit','Units','Normalized','String','0.001','BackgroundColor','white',...
               'Position',[0.38,IPOS,width,height]);
           
           %NUMBER EPOCHS
           h.ANN.epochs_text = uicontrol('Parent',npanel,'Style','text','Units','Normalized','String','Epochs:','FontSize',10,...
               'Position',[obj.INTERFACE.DEFAULT_TEXT_WIDTH+obj.INTERFACE.DEFAULT_SEPARATION*2+obj.INTERFACE.DEFAULT_POPUP_WIDTH,IPOS,obj.INTERFACE.DEFAULT_TEXT_WIDTH,height],'HorizontalAlignment','Left');
           h.ANN.epochs_edit = uicontrol('Parent',npanel,'Style','edit','Units','Normalized','String',num2str(obj.INTERFACE.DATA.EPOCHS),'BackgroundColor','white',...
               'Position',[obj.INTERFACE.DEFAULT_TEXT_WIDTH+obj.INTERFACE.DEFAULT_SEPARATION+obj.INTERFACE.DEFAULT_POPUP_WIDTH+obj.INTERFACE.DEFAULT_TEXT_WIDTH/2+obj.INTERFACE.DEFAULT_SEPARATION,IPOS,width,height]);
            
 
      end

      function [SP SS AC A] = train(obj,P,T,Test,T2)
          global h;
          
          
          target_selected = obj.DATA.TARGET_SELECTED;
          
          net_names=fieldnames(obj.DATA.layers)
          n_nn=numel(net_names);
          
          
          p_fields=fieldnames(T);
            n_tar=numel(p_fields);
            n_inp_sets=numel(fieldnames(P));
           
            
            for np=1:n_tar%Vary Datasets
          
          
          for n=1:n_nn
          
              lay_names=fieldnames(obj.DATA.layers.(net_names{n}));
              n_lay=numel(lay_names);
              neu_str='';
              neu_mat=[];
              tf_mat=[];
              for l=1:n_lay
                  n_neu=numel(obj.DATA.layers.(net_names{n}).(lay_names{l}).neu)
                  
                  tf_mat=[tf_mat,obj.DATA.layers.(net_names{n}).(lay_names{l}).actf];
                  
                  neu_str=[neu_str,sprintf('for n%d=1:%d\n',l,n_neu)]
                
              end
              
              neu_str=[neu_str,sprintf('neu_mat=[neu_mat;[')];
              
              for l=1:n_lay
                neu_str=[neu_str,sprintf('obj.DATA.layers.(net_names{n}).(lay_names{%d}).neu(n%d) ',l,l)];
              end
              
              neu_str=[neu_str,sprintf(']]\n')];
              
              for l=1:n_lay
                  neu_str=[neu_str,sprintf('end\n')];
              end
              
              neu_str
          eval(neu_str);
              
           for k=1:size(neu_mat,1) 
               
               if n_tar==n_inp_sets
                Pi = P.(p_fields{np})';
                
            else
                if np==1
                    Pi = P.(p_fields{np})';
                end
                
            end
            Testi = Test.(p_fields{end})';

               

               Ti = T.(p_fields{np});
                %h.P = P.;
                T2i = T2.(p_fields{np});

          %[SP SS AC] = PredictionAlgorithms.calcPerformance(A,T2i)
          
          
          
          lr = num2str(get(h.ANN.lr_edit, 'String'));
          d = num2str(get(h.ANN.dropout_edit, 'String'));
          w = num2str(get(h.ANN.reg_edit, 'String'));
          sop = num2str(get(h.ANN.pictal_edit, 'String'));
          seq_length = num2str(get(h.ANN.seq_edit, 'String'));
          nb_epoch = num2str(get(h.ANN.epochs_edit, 'String'));
          optimizer = get(h.ANN.train_function_popup, 'String');
          optimizer = optimizer(get(h.ANN.train_function_popup, 'Value'));
          optimizer = char(optimizer);
          neu_mat = num2str(neu_mat);

          
          if target_selected == 1
              Ti(Ti==3) = 1;
              Ti(Ti==4) = 1;
              T2i(T2i==3) = 1;
              T2i(T2i==4) = 1;
          end
          dirpath = '+PredictionAlgorithms/+Artificial_Neural_Networks/+Types/tmp/';
          if ~exist(dirpath,'dir') mkdir(dirpath); end
          csvwrite('+PredictionAlgorithms/+Artificial_Neural_Networks/+Types/tmp/P.csv',Pi);
          csvwrite('+PredictionAlgorithms/+Artificial_Neural_Networks/+Types/tmp/T.csv',Ti');
          csvwrite('+PredictionAlgorithms/+Artificial_Neural_Networks/+Types/tmp/Ptest.csv',Testi);
          csvwrite('+PredictionAlgorithms/+Artificial_Neural_Networks/+Types/tmp/Ttest.csv',T2i');
          system(strcat(['/home/rsp/anaconda2/bin/python +PredictionAlgorithms/+Artificial_Neural_Networks/+Types/lstm_epi.py '...
              ,' ',lr,' ',d,' ',w,' ',sop,' ',seq_length,' ',nb_epoch,' ',optimizer,' ',neu_mat]))
          A = csvread('+PredictionAlgorithms/+Artificial_Neural_Networks/+Types/tmp/A.csv');
          
          %Save Features and Target to File  
            %obj.DATA.firing_power_alarm=0.5;
            
            
            cd 
%                A2 = zeros(length(T2),1);
%                for i=1:length(T2) % Convert the A into a 1,2,3,4 format
%                     aux=max(A(:,i));
%                     A2(i) = find(A(:,i)==max(A(:,i)));
% 
%                     if(aux > 0) %Allow a more detailed plot
%                       A2(i) = A2(i) + (aux-1);
%                     else
%                       A2(i) = A2(i) + (aux+1);
%                     end    
%                end
               
%                A2=real2th(A',[obj.DATA.NORMAL_STATE obj.DATA.PRE_ICTAL_STATE obj.DATA.ICTAL_STATE obj.DATA.POS_ICTAL_STATE]);
               
                %A=real2th(A',[obj.DATA.NORMAL_STATE obj.DATA.PRE_ICTAL_STATE obj.DATA.ICTAL_STATE obj.DATA.POS_ICTAL_STATE]);
            
            A2 = A;
            T2i = T2i(str2num(seq_length)+1:end);
            disp('sizes')
            size(A2)
            size(T2i)
            [SP SS AC]=obj.calcPerformance(A2,T2i)
            obj.DATA.SP=SP;
            obj.DATA.SS=SS;
            obj.DATA.AC=AC;
            A=A';
            obj.DATA.A=A2;
            obj.DATA.T2=T2i;
               
               
               
               [out,tint,time_out,tar]=class2alarm(obj.DATA.test_time_vec,A2,T2i,obj.DATA.PRE_ICTAL_TIME(np),obj.DATA.PRE_ICTAL_STATE,obj.DATA.pAcq,obj.DATA.firing_power_alarm);
               [SS_AL,FPR,hours_estim,nseiz]=eval_results_alarm(out,tar);
               if SS_AL>0
                    time=time_out+obj.DATA.test_time_start;
                    evts=obj.DATA.STUDY.dataset.results.feat_events;
                    [min_ant,max_ant,avg_ant,std_ant]=eval_ant_times(time,tar,out,obj.DATA.PRE_ICTAL_TIME(np),evts)
                else
                    min_ant=NaN;
                    max_ant=NaN;
                    avg_ant=NaN;
                    std_ant=NaN;
                end
               
               
               obj.DATA.SS_AL=SS_AL;
               obj.DATA.FPR=FPR;
               obj.DATA.TIME_AL=time_out;
               obj.DATA.OUT_AL=out;
               obj.DATA.TAR_AL=tar;
          
               
               obj.DATA.MIN_ANT=min_ant;
                obj.DATA.MAX_ANT=max_ant;
                obj.DATA.AVG_ANT=avg_ant;
                obj.DATA.STD_ANT=std_ant;
          
          
          obj.DATA.model.('Layers')=neu_mat(k,1:end-1);
                   obj.DATA.model.('Transfer_Functions')=obj.DATA.TRANSFER_FUNCTIONS(tf_mat(1:end-1));
                   obj.DATA.model.('Firing_pow')=obj.DATA.firing_power_alarm;
                   obj.DATA.model.('SP')=SP;
                   obj.DATA.model.('SS')=SS;
                   obj.DATA.model.('AC')=AC;
                   obj.DATA.model.('FPR')=obj.DATA.FPR;
                   obj.DATA.model.('SS_AL')=obj.DATA.SS_AL;
                   obj.DATA.model.('REL')=obj.DATA.REL;
                   obj.DATA.model.('Tar')=obj.DATA.T2;
                   obj.DATA.model.('Out')=obj.DATA.A;
                   obj.DATA.model.('Time')=obj.DATA.test_time_vec;
                   obj.DATA.model.('Tar_al')=obj.DATA.TAR_AL;
                   obj.DATA.model.('Out_al')=obj.DATA.OUT_AL;
                   obj.DATA.model.('Time_al')=obj.DATA.TIME_AL;
                   
                   obj.DATA.model.('Train_start_idx')=obj.DATA.train_time_start_idx;
                   obj.DATA.model.('Train_stop_idx')=obj.DATA.train_time_end_idx;
                   obj.DATA.model.('Train_start')=obj.DATA.train_time_start;
                   obj.DATA.model.('Train_stop')=obj.DATA.train_time_end;
                    
                   obj.DATA.model.('Test_start_idx')=obj.DATA.test_time_start_idx;
                   obj.DATA.model.('Test_stop_idx')=obj.DATA.test_time_end_idx;
                    obj.DATA.model.('Test_start')=obj.DATA.test_time_start;
                    obj.DATA.model.('Test_stop')=obj.DATA.test_time_end;
                    
                    obj.DATA.model.('Is_equal_classes')=obj.DATA.is_equal_classes;
      
                    obj.DATA.model.('Inp_features')=obj.DATA.inp_feat;
                    obj.DATA.model.('Inp_features_idx')=obj.DATA.inp_feat_idx;
                    obj.DATA.model.('Pictal')=obj.DATA.PRE_ICTAL_TIME(np);
                   
                   obj.DATA.model.('Pictal_state')=obj.DATA.PRE_ICTAL_STATE;
%                    obj.DATA.model.('net')=net;
                   obj.DATA.model.('norm_factors')=obj.DATA.norm_factors;
                   
                   
                   obj.DATA.model.('MAX_ANT')=obj.DATA.MAX_ANT;
                   obj.DATA.model.('MIN_ANT')=obj.DATA.MIN_ANT;
                   obj.DATA.model.('AVG_ANT')=obj.DATA.AVG_ANT;
                   obj.DATA.model.('STD_ANT')=obj.DATA.STD_ANT;
                    
                    nn_res=obj.DATA.STUDY.dataset.results.classifiers.Artificial_Neural_Networks;
                   
                   nn_res={nn_res{:},obj.DATA.model};
                   
                   obj.DATA.STUDY.dataset.results.classifiers.Artificial_Neural_Networks=nn_res;
          
          
          
          end
          end
            end
      end
      
      function updateData(obj)
          global h;
          obj.DATA.PRE_ICTAL_TIME=eval(get(h.ANN.pictal_edit, 'String')).*60;
          obj.DATA.EPOCHS = str2double(get(h.ANN.epochs_edit, 'String'));
%           obj.DATA.GOAL = str2double(get(h.ANN.goal_edit, 'String'));
%           obj.DATA.TRAINING_FUNCTIONS_POS = get(h.ANN.training_function_popup, 'Value');
%           obj.DATA.LEARNING_FUNCTIONS_POS = get(h.ANN.learning_function_popup, 'Value');
          
          obj.DATA.EARLY_DETECT_TIME=eval(get(h.ANN.early_detect_edit, 'String'));
          
      end
      function [SP SS AC NERRORS] = calcPerformance(obj, A, T2) 
        %Classes:
        %1 - Normal state
        %2 - Pre-ictal 
        %3 - Ictal
        %4 - Pos-ictal
        %T2 - Must have 1 column and n rows with the classes
        
            size(A)
            size(T2)
            NORMAL=obj.DATA.NORMAL_STATE;
            PREICTAL=obj.DATA.PRE_ICTAL_STATE;
            ICTAL=obj.DATA.ICTAL_STATE;
            POSICTAL=obj.DATA.POS_ICTAL_STATE;        

            %0 Calc the total number of errors and corrects
            NERRORS=zeros(4);
            CORRECTS=zeros(4,1);
            for i=1:length(A)
                aux=A(i);
                
                if aux>obj.DATA.POS_ICTAL_STATE
                    aux=obj.DATA.POS_ICTAL_STATE;
                else if aux<obj.DATA.NORMAL_STATE
                        aux=obj.DATA.NORMAL_STATE;
                    end
                end
                NERRORS(T2(i),aux(1))=NERRORS(T2(i),aux(1))+(T2(i)~=aux(1));
                CORRECTS(T2(i))=CORRECTS(T2(i))+(T2(i)==aux(1)); %Add the correct situations
            end

            %1 Calc TP, TN, FP, FN
            %1.1 True Negatives
            TN_NORMAL=(CORRECTS(NORMAL)+NERRORS(ICTAL,NORMAL)+NERRORS(POSICTAL,NORMAL));
            TN_ICTAL=(NERRORS(NORMAL,ICTAL)+CORRECTS(ICTAL)+NERRORS(POSICTAL,ICTAL));
            TN_POSICTAL=(NERRORS(NORMAL,POSICTAL)+NERRORS(ICTAL,POSICTAL)+CORRECTS(POSICTAL));
            TN=TN_NORMAL+TN_ICTAL+TN_POSICTAL;
            disp({'Neg Verdadeiros=' TN});

            %1.2 False Negatives
            FN=NERRORS(PREICTAL,NORMAL)+NERRORS(PREICTAL,ICTAL)+NERRORS(PREICTAL,POSICTAL);
            disp({'Neg Falsos=' FN});

            %1.3 True Positives
            TP=CORRECTS(PREICTAL);
            disp({'Pos Verdadeiros=' TP});

            %1.4 False Positives
            FP=NERRORS(NORMAL,PREICTAL)+NERRORS(ICTAL,PREICTAL)+NERRORS(POSICTAL,PREICTAL);
            disp({'Pos Falsos=' FP});


            %2. Metrics
            %2.1 Calc the sensitivity (TP/TP+FN)
            SS = (TP/(TP+FN))*100; 

            %2.2 Calc the specificity (TN/TN+FP)
            SP = (TN/(TN+FP))*100;  

            %2.3 Calc the classifier precision (CORRECT/TOTAL)
            CORRECT=sum(CORRECTS);
            TOTAL=length(T2);
            AC = (CORRECT/TOTAL)*100;


           
            end
      
   end
end
