% getting the .wav file + its frequency + duration
file = inputdlg('Enter the required wav file name in the format (filename.wav):');
[y,fs] = audioread(file{1});
duration=length(y)/fs;
ofs=str2double(inputdlg('Specify the required output sample rate in Hz:'));
t = linspace(0,duration,length(y)); %time axis to plot any time domain input signals either before or after filtering


%getting the db of the different frequency ranges:
ranges = [0 170 310 600 1000 3000 6000 12000 14000 16000];
gains = [];
for i = 1:length(ranges)-1
    decibel = str2double(inputdlg(['Enter the required gain in dB for the frequency range from' num2str(ranges(i)) 'Hz to ' num2str(ranges(i+1)) 'Hz :']));
    gains = [gains decibel];
end
%choosing the type of filter (IIR or FIR):
filterType = menu('Choose the type of filter required:','IIR','FIR');


%%filtering the passed audio
filters = []; %an array of the filtered signals
ampFilter = []; %an array of amplified filtered signals
compositeSignal = 0;  %output signal

%wn = wc/(fs/2) --> to follow nyquist role and apply normaliaztion
        %where the butter/fir1 functions takes wc in (0,1) range
ni = 1;
nf = 600;
if filterType == 1 %IIR
    for i = 1:9        
        switch i
            case 1
                [num1 den1] = butter(ni, 2*170/fs,'low');
                filters = [filters filter(num1,den1,y)];
                
            case 2
                [num2 den2] = butter(ni, [2*170/fs,2*310/fs],'bandpass');
                filters = [filters filter(num2,den2,y)];
                
            case 3
                [num3 den3] = butter(ni, [2*310/fs,2*600/fs],'bandpass');
                filters = [filters filter(num3,den3,y)];
                
            case 4
                [num4 den4] = butter(ni, [2*600/fs,2*1000/fs],'bandpass');
                filters = [filters filter(num4,den4,y)];
                
            case 5
                [num5 den5] = butter(ni, [2*1000/fs,2*3000/fs],'bandpass');
                filters = [filters filter(num5,den5,y)];
                
            case 6
                [num6 den6] = butter(ni, [2*3000/fs,2*6000/fs],'bandpass');
                filters = [filters filter(num6,den6,y)];
                
            case 7
                [num7 den7] = butter(ni, [2*6000/fs,2*12000/fs],'bandpass');
                filters = [filters filter(num7,den7,y)];
                
            case 8
                [num8 den8] = butter(ni, [2*12000/fs,2*14000/fs],'bandpass');
                filters = [filters filter(num8,den8,y)];
               
            case 9
                [num9 den9] = butter(ni, [2*14000/fs,2*16000/fs],'bandpass');
                filters = [filters filter(num9,den9,y)];
                
        end
        ampFilter = [ampFilter (10^(gains(i)/20))*filters(:,i)];
        compositeSignal = compositeSignal + ampFilter(:,i);
    end
else %FIR  
    for i = 1:9
         switch i   %type of default window fir1 --> hamming window
            case 1
                [num1 den1] = fir1(nf, 2*170/fs,'low');
                filters = [filters filter(num1,den1,y)];
                
            case 2
                [num2 den2] = fir1(nf, [2*170/fs,2*310/fs],'bandpass');
                filters = [filters filter(num2,den2,y)];
                
            case 3
                [num3 den3] = fir1(nf, [2*310/fs,2*600/fs],'bandpass');
                filters = [filters filter(num3,den3,y)];
                
            case 4
                [num4 den4] = fir1(nf, [2*600/fs,2*1000/fs],'bandpass');
                filters = [filters filter(num4,den4,y)];
                
            case 5
                [num5 den5] = fir1(nf, [2*1000/fs,2*3000/fs],'bandpass');
                filters = [filters filter(num5,den5,y)];
                
            case 6
                [num6 den6] = fir1(nf, [2*3000/fs,2*6000/fs],'bandpass');
                filters = [filters filter(num6,den6,y)];
                
            case 7
                [num7 den7] = fir1(nf, [2*6000/fs,2*12000/fs],'bandpass');
                filters = [filters filter(num7,den7,y)];
                
            case 8
                [num8 den8] = fir1(nf, [2*12000/fs,2*14000/fs],'bandpass');
                filters = [filters filter(num8,den8,y)];
               
            case 9
                [num9 den9] = fir1(nf, [2*14000/fs,2*16000/fs],'bandpass');
                filters = [filters filter(num9,den9,y)];
                
         end
         ampFilter = [ampFilter (10^(gains(i)/20))*filters(:,i)];
         compositeSignal = compositeSignal + ampFilter(:,i);
    end
end
 
%output signals after filtering & after filtering and amplification for each range
 for i = 1:9
    figure;
    sub1=subplot(3,2,1);
    plot(sub1,t,filters(:,i)); xlabel('time'); title(['From ' num2str(ranges(i)) ' to ' num2str(ranges(i+1)) 'after filtering only']);
    filterfreq=fftshift(fft(filters(:,i)/fs));
    f=linspace(-fs/2,fs/2,length(filterfreq));
    sub2=subplot(3,2,3);
    plot(sub2,f,abs(filterfreq)); xlabel('Magnitude Spectrum');
    sub3=subplot(3,2,5);
    plot(sub3,f,angle(filterfreq)); xlabel('Phase Spectrum');xlim([-1 1]);
    
    sub4=subplot(3,2,2);
    plot(sub4,t,ampFilter(:,i)); xlabel('time'); title(['From ' num2str(ranges(i)) ' to ' num2str(ranges(i+1)) 'after filtering & amplification']);
    filterfreq=fftshift(fft(ampFilter(:,i)/fs));
    f=linspace(-fs/2,fs/2,length(filterfreq));
    sub5=subplot(3,2,4);
    plot(sub5,f,abs(filterfreq)); xlabel('Magnitude Spectrum');
    sub6=subplot(3,2,6);
    plot(sub6,f,angle(filterfreq)); xlabel('Phase Spectrum');xlim([-1 1]);
 end

 
%plot the signal in time & frequency domain before and after
figure;
sub1=subplot(3,2,1);
plot(sub1,t,y); xlabel('time domain plot'); title('Whole Signal Before Amplification');
yf=fftshift(fft(y/fs));
f=linspace(-fs/2,fs/2,length(yf));
sub2=subplot(3,2,3);
plot(sub2,f,abs(yf));
xlabel('Magnitude Spectrum');
sub3=subplot(3,2,5);
plot(sub3,f,angle(yf));
xlabel('Phase Spectrum');
xlim([-1 1]);
sub4=subplot(3,2,2);
to = linspace(0,length(compositeSignal)/ofs,length(compositeSignal)); %an axis for output signal using the output sampling frequency recevied from user
plot(sub4,to,compositeSignal);xlabel('time domain plot');title('Whole Signal After Amplification');
compositeSignalF=fftshift(fft(compositeSignal/ofs));
f=linspace(-ofs/2,ofs/2,length(compositeSignalF));
sub5=subplot(3,2,4);
plot(sub5,f,abs(compositeSignalF));xlabel('Magnitude Spectrum');
sub6=subplot(3,2,6);
plot(sub6,f,phase(compositeSignalF));xlabel('Phase Spectrum');xlim([-1 1]);

 
% play and save the composite wave signal to a wav file
sound(compositeSignal,ofs);
audiowrite('compositeSignal.wav',compositeSignal,ofs);
 

%Analysis

choice=menu('Do you want to analyse a filter?', 'Yes','No');
if choice == 1
    while(1)
        choice1=menu('Choose a filter', '1( 0- 170 Hz)','2( 170- 310 Hz)','3( 310- 600 Hz)','4( 600- 1000 Hz)','5( 1- 3 KHz)','6( 3- 6 KHz)','7( 6-12 KHz)','8( 12-14 KHz)','9( 14-16 KHz)','10-Exit');
        if choice1 ~=10
            switch choice1
                case 1
                    a = num1;
                    b = den1;
                case 2
                    a = num2;
                    b = den2;
                case 3
                    a = num3;
                    b = den3;
                case 4
                    a = num4;
                    b = den4;
                case 5
                    a = num5;
                    b = den5;
                case 6
                    a= num6;
                    b = den6;
                case 7
                    a = num7;
                    b = den7;
                case 8
                    a = num8;
                    b = den8;
                case 9
                    a= num9;
                    b = den9;
            end
            choice2=menu('Choose from the following','zeros/poles','gain','phase','order','impulse response','step response');
            switch choice2
                case 1
                    [z,p,k]=tf2zpk(a,b); %get the poles, zeros, gain of the filter
                    disp('zeros:'); disp(z)
                    disp('poles:'); disp(p) %display zeroes and poles to command window
                    figure; zplane(z,p); title('Z-plane Plot'); %plot zeroes and poles
                case 2
                    [z,p,k]=tf2zpk(a,b); %get gain of filter (returns gain before amplification)
                    disp('gain:'); disp(k);
                case 3
                    [H w] = freqz(a,b) %get the phase  of the filter
                    figure; sub1 = subplot(2,1,1);
                    plot(sub1,w,20*log(10)*abs(H)); xlabel('Magnitude response of filter');
                    sub2 = subplot(2,1,2);
                    plot(sub2,w,angle(H)); xlabel('Phase response of filter');
                case 4
                    n=filtord(a,b);%get the order of the filter
                    disp('order:'); disp(n);
                case 5
                    [h,t] = impz(a,b);%get the impulse response of the filter
                    figure; stem(h); title('impulse response of filter');
                case 6
                    [s,t] = stepz(a,b);%get the step response of the filter
                    figure;stem(s);title('step response of filter');
            end
        else
            break;
        end
    end
end
