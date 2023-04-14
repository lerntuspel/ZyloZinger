%% Plotting the Spectrogram and Audio

[y, Fs] = audioread('Users/rajatyagi/Downloads/ToyPianoScales.wav');

% Fs = 8000;
% y = resample(y,Fs,fs);

duration = length(y)/Fs;
t = 0: 1/Fs : duration - 1/Fs;
fft_size = 1024;

win = ones(1024,1);
figure(1)
spectrogram(y,win,0,fft_size,Fs,'yaxis');
figure(2)
plot(t, y);

%% Plotting FFT

% Tone 1
start_time = 0;
end_time = 0.1;

% Tone 2
% start_time = 1;
% end_time = 1.7;

% Tone 3
% start_time = 1.9;
% end_time = 2.5;

% Tone 4
% start_time = 2.8;
% end_time = 3.5;

tone1 = y(start_time*Fs + 1:end_time*Fs);

% tone1 = decData;
% figure(3)
plot(t(start_time*Fs + 1:end_time*Fs),tone1);
F_t1 = (fft(tone1, fft_size));
freq = -numel(F_t1)/2 : 1 : numel(F_t1)/2 - 1;
figure(3)
% plot(Fs*freq/fft_size, abs(F_t1));
plot(abs(F_t1));

%% Implementing FFT bin calculation using Goertzel's Algorithm

% Bins that were looking for. (Should be changed if we change the sampling frequency)

bins = [201, 228, 254, 266, 298, 333, 377, 400, 9];

x = tone1(1:fft_size);

% Calcualtion of bin amplitude

X = zeros(9,1);

for i = 1:9
   
    X(i) = goertzel(x,bins(i));
    disp(X(i))
end

% Finding the bin associated to the tone

[~, max_idx] = max(X);

disp(bins(max_idx))

%% Saving Audio as txt file

x_fp = x .* 256;
x_fp = floor(x_fp);

fid = fopen('tone_bin_201.txt', 'w');
fprintf(fid,'%d\n',x_fp);
fclose(fid);

%% Read Audio codec data

fileID = fopen('test02_helooo.txt','r');
A = fscanf(fileID,'%x');
% q = quantizer('fixed', 'nearest', 'saturate', [10 0]);% quantizer object for num2hex function
% decData = hex2num(q, A{1});
% decData = cell2mat(decData);
decData = twos2decimal(A,32);
fclose(fileID);

% A = 5*(A)/max(A);

%% Functions

function X_k = goertzel(x,bin)

    fft_size = length(x);
    v = 0;
    v_1 = 0;
    v_2 = 0;

    for i = 1:fft_size
        v = x(i) + 2*cos(2*pi*bin/fft_size)*v_1 - v_2;
        v_2 = v_1;
        v_1 = v;
    end
    
    X_k = v^2 + v_1^2 - 2*v*v_1*cos(2*pi*bin/fft_size);

end



function [decimal] = twos2decimal(x,bits)
    %  twos2decimal(data,bits)  convert 2s complement to decimal
    %                           data - single value or array to convert
    %                           bits - how many bits wide is the data (i.e. 8
    %                           or 16)
    decimal=zeros(length(x),1);
    for i=1:length(x)
        if bitget(x(i),bits) == 1
            decimal(i) = (bitxor(x(i),2^bits-1)+1)*-1;
        else
            decimal(i) = x(i);
        end
    end
end