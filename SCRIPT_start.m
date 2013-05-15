
clear all
close all

SCRIPT_setEnviromet();

measure=[];

%---------- MAIN LOOP -------------

action='';

while ~strcmp(action,'exit' )
    [hmain action]=GUI_start();

    
    %%NEW MEASURE
    if strcmp(action,'new' )
        if (ishandle(hmain))
            close(hmain);
        end

        measure=SCRIPT_newMeasure(measure);
    
    %%LOAD MEASURE
    elseif strcmp(action,'load' )
        if (ishandle(hmain))
            close(hmain);
        end
        SCRIPT_loadMeasure();      
    end
    
    
end

if (ishandle(hmain))
        disp('MAIN - closing handle');
        close(hmain);
end

clear all
close all