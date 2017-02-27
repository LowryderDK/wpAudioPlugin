classdef myFilter < audioPlugin
    %myFilter Biquad highpass filter
    %   Filter c
    
    properties
        Fc = 50
    end
    
    properties (Constant)
        PluginInterface = audioPluginInterface(audioPluginParameter('Fc','Mapping',{'log', 50, 5000}))
    end
    properties
        % internal states
        b = zeros(1,3)
        a = ones(1,3) 
        z = zeros(2)
    end
    
    methods
        function out = process(p, in)
            [out, p.z] = filter(p.b, p.a, in, p.z);
        end
        
        function reset(p)
           p.z = zeros(2);
           [p.b, p.a] = highPassCoeffs(p.Fc, getSampleRate(p));
           setupMIDIControls(p);
        end
        
        function setupMIDIControls(obj)
            configureMIDI(obj,'Fc',1009,'DeviceName','Teensy MIDI');
        end

        function set.Fc(p,Fc)
            p.Fc = Fc;
            [p.b, p.a] = highPassCoeffs(p.Fc, getSampleRate(p));
        end
    end
    
end

% Butterworth highpass
function [b, a] = highPassCoeffs(Fc, Fs)
  w0 = 2*pi*Fc/Fs;
  alpha = sin(w0)/sqrt(2);
  cosw0 = cos(w0);
  norm = 1/(1+alpha);
  b = (1 + cosw0)*norm * [.5  -1  .5];
  a = [1  -2*cosw0*norm  (1 - alpha)*norm];
end
