%%Signal and Channel Parameters

% System simulation parameters
Fs = 1;           % sampling frequency (notional)
nBits = 2048;     % number of BPSK symbols per vector
maxErrs = 200;    % target number of errors at each Eb/No
maxBits = 1e6;    % maximum number of symbols at each Eb/No

% Modulated signal parameters
M = 2;                     % order of modulation
Rs = Fs;                   % symbol rate
nSamp = Fs/Rs;             % samples per symbol
Rb = Rs*log2(M);           % bit rate

% Channel parameters
chnl = [0.460 0.688 0.460]';  % channel impulse response
chnlLen = length(chnl);       % channel length, in samples
EbNo = 0:14;                  % in dB
BER = zeros(size(EbNo));      % initialize values

% Create BPSK modulator
bpskMod = comm.BPSKModulator;

% Specify a seed for the random number generators to ensure repeatability.
rng(45)

%%Adaptive Equalizer Parameters
tbLen = 30;                        % MLSE equalizer traceback length
numStates = M^(chnlLen-1);         % number of trellis states
[mlseMetric,mlseStates,mlseInputs] = deal([]);
const = constellation(bpskMod);    % signal constellation
mlseType = 'ideal';                % perfect channel estimates at first
mlseMode = 'cont';                 % no MLSE resets

% Channel estimation parameters
chnlEst = chnl;         % perfect estimation initially
prefixLen = 2*chnlLen;  % cyclic prefix length
excessEst = 1;          % length of estimated channel impulse response
                        % beyond the true length
const = constellation(bpskMod);    % signal constellation
% Linear equalizer parameters
nWts = 31;               % number of weights
algType = 'RLS';         % RLS algorithm
forgetFactor = 0.999999; % parameter of RLS algorithm

% DFE parameters - use same update algorithms as linear equalizer
nFwdWts = 15;            % number of feedforward weights
nFbkWts = 15;            % number of feedback weights

% Initialize the graphics for the simulation.  Plot the unequalized channel
% frequency response, and the BER of an ideal BPSK system.
idealBER = berawgn(EbNo,'psk',M,'nondiff');

[hBER, hLegend,legendString,hLinSpec,hDfeSpec,hErrs,hText1,hText2, ...
  hFit,hEstPlot,hFig,hLinFig,hDfeFig] = eqber_graphics('init', ...
  chnl,EbNo,idealBER,nBits);

%%Construct RLS and LMS Linear and DFE Equalizer Objects
linEq = comm.LinearEqualizer('Algorithm', algType, ...
  'ForgettingFactor', forgetFactor, ...
  'NumTaps', nWts, ...
  'Constellation', const, ...
  'ReferenceTap', round(nWts/2), ...
  'TrainingFlagInputPort', true);

dfeEq = comm.DecisionFeedbackEqualizer('Algorithm', algType, ...
  'ForgettingFactor', forgetFactor, ...
  'NumForwardTaps', nFwdWts, ...
  'NumFeedbackTaps', nFbkWts, ...
  'Constellation', const, ...
  'ReferenceTap', round(nFwdWts/2), ...
  'TrainingFlagInputPort', true);

firstRun = true;  % flag to ensure known initial states for noise and data
eqType = 'linear';
eqber_adaptive;

close(hFig(ishghandle(hFig)));

eqType = 'dfe';
eqber_adaptive;