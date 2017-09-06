%This class contains all the data necessary for loading and saving the ANN
classdef Artificial_Neural_Networks_Data < handle
    % The following properties can be set only by class methods
    properties
        
        %BEGIN: DO NOT REMOVE THESE PROPERTIES
        STUDY;
        
        %USED BY RESULTS LIST (SHOULD BE UPDATED IN INTERFACE CLASS)
        sub_module_name = 'Artificial_Neural_Networks';
        saveinfo_datasets; %Number of datasets used
        saveinfo_features; %Number of features used
        saveinfo_other;  %Other kind of information
        saveinfo_name = '';
        MenuitemCallback;
        SS = NaN;        %PERFORMANCE VALUES
        SP = NaN;
        AC = NaN;
        
        
        loading = 0;
        EPILAB_DS_FLAG = '_study';
        FEATURES_TAG = 'c_';
        
        PRE_ICTAL_TIME = 5*60; % 5 minutes (default)
        POS_ICTAL_TIME = 5*60; % 5 minutes
        NORMAL_STATE = 1;
        PRE_ICTAL_STATE = 2;
        ICTAL_STATE = 3;
        POS_ICTAL_STATE = 4;
        
        USE_SAME_MSEL=struct('train',0,'test',0,'preictal',0);%Introduced for manual selection
        
        EARLY_DETECT_TIME=10;
        
        
        %END: DO NOT REMOVE THESE PROPERTIES
        
        %Artificial Neural Networks
        NNETS = {};
        NNET_COMP = 'Competitive';
        NNET_COMP_conscience = 0.001;
        NNET_COMP_kohonen = 0.1;
        NNET_CFBP = 'Cascade-forward backprop';
        NNET_FFBP = 'Feed-forward backprop';
        NNET_ELMAN = 'Elman';
        NNET_RECURRENT = 'Recurrent';
        NNET_FFTD = 'Feed-forward time-delay';
        NNET_DTD = 'Feed-forward distributed time delay';
        NNET_LSTM = 'Long Short Term Memory';
        
        NNET_LIND = 'Linear Layer (Design)';
        NNET_LIN = 'Linear Layer (Train)';
        NNET_LIN_INPUTDELAY = [0];
        NNET_LIN_LEARNINGRATE = 0.01;
        NNET_LIN_EPOCHS = 1000;
        NNET_LIN_GOAL = 0.00001;
        NNET_LIN_TRAINING_FUNCTIONS_POS = 2;
        NNET_LIN_PERFORMANCE_FUNCTIONS_POS = 1;
        
        NNET_RBF = 'Radial basis (exact fit)';
        NNET_RBF_SPREAD = 1.5;
        
        NNET_RBFF = 'Radial basis (fewer neurons)';
        
        NNET_GENREG = 'Generalized regression';
        NNET_GENREG_SPREAD = 1.5;
        
        NNET_LVQ = 'Learning Vector Quantization';
        NNET_LVQ_HIDDENNEURONS = 10;
        NNET_LVQ_OUTPUT_CLASS = [0.47 0.05 0.03 0.45];
        NNET_LVQ_LEARNINGRATE = 0.01;
        NNET_LVQ_LEARNING_FUNCTIONS_POS = 1;
        NNET_LVQ_LEARNING_FUNCTIONS = {'LEARNLV1', 'LEARNLV2'};
        NNET_LVQ_EPOCHS = 150;
        NNET_LVQ_GOAL = 0.00001;
        NNET_LVQ_PERFORMANCE_FUNCTIONS_POS = 1;
        
        NNET_NARX = 'NARX Network';
        NNET_NARXSP = 'NARX Series-Parallel Network';
        NNET_PERCEPTRON = 'Perceptron';
        NNET_PROBABILISTIC = 'Probabilistic';
        
        %       NNET_SOM = 'Self-Organized Map'; TODO: Finish..
        %         ORD_PHASE_LEARNING = 0.9;
        %         ORD_PHASE_STEPS = 1000;
        %         TUNING_PHASE_LEARNING = 0.02;
        %         NEIGH_DISTANCE = 1.0;
        %         DIMENSIONS_MAP = [15 8];
        %         TOPOLOGY_FUNCTIONS_POS = 1;
        %         TOPOLOGY_FUNCTIONS = {'HEXTOP', 'GRIDTOP', 'RANDTOP'};
        %         DISTANCE_FUNCTIONS_POS = 1;
        %         DISTANCE_FUNCTIONS = {'LINKDIST', 'DIST', 'MANDIST'};
        
        %Training
        SPREAD_CONST = 1.5;
        TRAINING_FUNCTIONS_POS = 1;
        LEARNING_FUNCTIONS_POS = 1;
        PERFORMANCE_FUNCTIONS_POS = 1;
        TRAINING_FUNCTIONS = {'trainlm','trainb','trainbfg','trainbr','trainbuwb','trainc','traincgb','traincgf',...
            'traincgp','traingd','traingda','traingdm','traingdx','trainoss','trainr','trainrp','trains','trainscg'};
        TRAINING_FUNCTIONS_LSTM = {'adam','RMSprop'}
        TRANSFER_FUNCTIONS = {'tansig','logsig','purelin'};
        TRANSFER_FUNCTIONS_LSTM = {'sigmoid','tanh_af'};
        TRANSFER_FUNCTIONS_POS = 1;
        TRANSFER_FUNCTIONS_PERCP = {'hardlim','hardlims'};
        PERFORMANCE_FUNCTIONS = {'mse', 'msereg', 'sse'};
        PERFORMANCE_FUNCTIONS_LSTM = {'cross entropy'};
        LEARNING_FUNCTIONS = {'learngdm','learngd'};
        LEARNING_FUNCTIONS_PERCP =  {'learnp','learnpn'};
        
        EPOCHS = 100;
        GOAL = 0.00001;
        INPUT_DELAY=[0 1];
        OUTPUT_DELAY=[1 2];
        
        %Train types
        TRAIN_TYPE_MERGE7030 = 'Train: All(70%) | Test: All(30%)';
        TRAIN_TYPE_MERGE_1 = 'Train: All-Last | Test: Last';
        TRAIN_TYPE_MERGE = 'Train: All | Test: Last';
        TRAIN_TYPE_MANUAL = 'Visual Selection';
        TRAIN_TYPE_MANUAL_PREV = 'Train: Prev. manual selection';
        TRAIN_TYPE_FROM_FILE = 'Parameters in file';
        TRAIN_TYPE_EQUAL = 'Train: Equalised Classes';
        TRAIN_TYPES = {};
        TRAIN_TYPES_SEL = 1;
        
        TARGET_CLASSES = {'2 (PREICTAL,NON-PREICTAL)', '4 (NORMAL,PREICTAL,ICTAL,NON-PREICTAL)'};
        TARGET_SELECTED = 1;
        
        %DATA SETS
        DATA_SETS_PATHS = {};
        PATHNAME = '';
        DATA_SETS = {};
        DATA_SETS_SEL = [];
        DATA_SETS_LAST_POS = 1;
        FEATURES = {};
        FEATURES_LIST = {};
        
        %ANN Layers
        NUMBER_LAYERS = 2;
        DELAY_VECTOR = {[0 1] []}
        layers = [struct('layer1',struct('neu',[15],'actf',1),'layer2',struct('neu',[4],'actf',1))];      %[Number_of_neurons position_of_transfer_function (1st layer); ...]
        
        %Results
        A = [];
        T2 = [];
        
        test_time_vec=[];
        pictal_delta=[];
        pAcq=[];
        firing_power_alarm=0.5;
        n_delay=0;
        
        SS_AL=NaN;
        FPR=NaN;
        REL='';
        OUT_AL;
        TIME_AL;
        TAR_AL;
        
        MIN_ANT;
        MAX_ANT;
        AVG_ANT;
        STD_ANT;
        
        
        % AL_LEV=50;
        
        train_time_start_idx;
        train_time_end_idx;
        train_time_start;
        train_time_end;
        
        test_time_start_idx;
        test_time_end_idx;
        test_time_start;
        test_time_end;
        
        is_equal_classes;
        inp_feat;
        inp_feat_idx;
        norm_factors;
        model=[];
        
    end
    
    methods
        %Constructor
        function obj = Artificial_Neural_Networks_Data()
            obj.TRAIN_TYPES = {obj.TRAIN_TYPE_MANUAL,obj.TRAIN_TYPE_FROM_FILE};
            obj.NNETS = {obj.NNET_FFBP, obj.NNET_ELMAN, obj.NNET_RECURRENT, obj.NNET_FFTD, obj.NNET_DTD, obj.NNET_RBF, obj.NNET_RBFF, obj.NNET_COMP, obj.NNET_CFBP, obj.NNET_GENREG, obj.NNET_LIND, obj.NNET_LIN, obj.NNET_LVQ, obj.NNET_NARX, obj.NNET_NARXSP, obj.NNET_PERCEPTRON, obj.NNET_PROBABILISTIC, obj.NNET_LSTM};
        end
        
    end
end