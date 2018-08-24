classdef mpr121 < arduinoio.LibraryBase 
    properties(Access = private, Constant = true)
        CREATE_MPR121_DRIVER = hex2dec('00')
        DELETE_MPR121_DRIVER = hex2dec('01')
        TOUCHED_MPR121_DRIVER = hex2dec('02')
    end
    
    properties(Access = protected, Constant = true)
        LibraryName = 'Adafruit/MPR121'
        DependentLibraries = {'I2C'}
        ArduinoLibraryHeaderFiles = 'Adafruit_MPR121/Adafruit_MPR121.h'
        CppHeaderFile = fullfile(arduinoio.FilePath(mfilename('fullpath')), 'src', 'MPR121Base.h')
        CppClassName = 'MPR121Base'
        
    end
    
    properties(Access = private)
        ResourceOwner = 'AdafruitMPR121';
        I2CAddress = hex2dec('5A');  
        Bus;
    end
  
    methods(Hidden, Access = public)
        function obj = mpr121(parentObj)
            obj.Parent = parentObj;
            count = getResourceCount(obj.Parent,obj.ResourceOwner);
            % Since this example allows implementation of only 1
            % shield, error out if resource count is more than 0
            if count > 0
                error('You can only have 1 MPR121 Capacitive Driver');
            end 
            incrementResourceCount(obj.Parent,obj.ResourceOwner);
            configureI2C(obj);
            %createMPR121(obj);
        end
        
        function status = createMPR121(obj)
            try
                % Initialize command ID for each method for appropriate handling by
                % the commandHandler function in the wrapper class.
                cmdID = obj.CREATE_MPR121_DRIVER;
                %inputs = uint8(obj.I2CAddress);
                inputs = [];
                
                % Call the sendCommand function to link to the appropriate method in the Cpp wrapper class
                output = sendCommand(obj, obj.LibraryName, cmdID, inputs);
                status = char(output');
            catch e
                throwAsCaller(e);
            end
        end
    end
    
    methods(Access = protected)
        function delete(obj)
            try
                parentObj = obj.Parent;
                % Decrement the resource count
                decrementResourceCount(parentObj, obj.ResourceOwner);
                cmdID = obj.DELETE_MPR121_DRIVER;
                inputs = [];
                sendCommand(obj, obj.LibraryName, cmdID, inputs);
            catch
                % Do not throw errors on destroy.
                % This may result from an incomplete construction.
            end
        end  
    end
    
    methods(Access = public)
        function touched = touchedMPR121(obj)
            cmdID = obj.TOUCHED_MPR121_DRIVER;
            inputs = [];
            output = sendCommand(obj, obj.LibraryName, cmdID, inputs);
            %touched = char(output');
            touched = output;
        end      
    end
    
    methods(Access = private)
        function configureI2C(obj)
            parentObj = obj.Parent;
            I2CTerminals = parentObj.getI2CTerminals();
            
            if ~strcmp(parentObj.Board, 'Due')
                obj.Bus = 0;
                resourceOwner = '';
                sda = parentObj.getPinsFromTerminals(I2CTerminals(obj.Bus*2+1)); sda = sda{1};
                configurePinResource(parentObj, sda, resourceOwner, 'I2C', false);
                scl = parentObj.getPinsFromTerminals(I2CTerminals(obj.Bus*2+2)); scl = scl{1};
                configurePinResource(parentObj, scl, resourceOwner, 'I2C', false);
                obj.Pins = {sda scl};
            else
                obj.Bus = 1;
                obj.Pins = {'SDA1', 'SCL1'};
            end
        end
    end
end