classdef ZekiyeAyperiTATAR_310206043_app < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        NoteDurationEditFieldLabel    matlab.ui.control.Label
        TotalDurationEditFieldLabel   matlab.ui.control.Label
        SamplingFrequencyFsEditFieldLabel  matlab.ui.control.Label
        CutoffFrequencyPairDropDown   matlab.ui.control.DropDown
        CutoffFrequencyPairDropDownLabel  matlab.ui.control.Label
        ApplyFilterButton             matlab.ui.control.Button
        PassbandNoteDropDown          matlab.ui.control.DropDown
        NoteDurationEditField         matlab.ui.control.EditField
        PassbandNoteDropDownLabel     matlab.ui.control.Label
        FilterOrderDropDown           matlab.ui.control.DropDown
        TotalDurationEditField        matlab.ui.control.EditField
        FilterOrderDropDownLabel      matlab.ui.control.Label
        FilterTypeDropDown            matlab.ui.control.DropDown
        SamplingFrequencyFsEditField  matlab.ui.control.EditField
        FilterTypeDropDownLabel       matlab.ui.control.Label
        PlayFilteredAudioButton       matlab.ui.control.Button
        PlayOriginalAudioButton       matlab.ui.control.Button
        secondsLabel_2                matlab.ui.control.Label
        secondsLabel                  matlab.ui.control.Label
        HzLabel                       matlab.ui.control.Label
        LoadAudioFileButton           matlab.ui.control.Button
        EE331FINALASSIGNMENTAPPLICATIONLabel  matlab.ui.control.Label
        FilteredSpectrumAxes          matlab.ui.control.UIAxes
        OriginalSpectrumAxes          matlab.ui.control.UIAxes
        FilteredSignalAxes            matlab.ui.control.UIAxes
        OriginalSignalAxes            matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        x;             % Audio
        Fs;            % Sampling frequency
        t;             % Time vector
        file_name;     % File's full path
        ref;           % Referance
        f0             % Fundamental frequency for the notes
        y;             % Filtered audio
        note_names = {'C4','D4','E4','F4','G4','A4','B4','C5'};
        note_segments = [0.12 0.61 ; 0.62 1.12 ; 1.13 1.62 ; 1.63 2.12 ; 2.13 2.62 ; 2.63 3.12 ; 3.13 3.62 ; 3.62 4.48];
        player_original;
        player_filtered;
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % Default UI Selections
            app.FilterTypeDropDown.Value = "Band-Pass Filter";
            app.FilterOrderDropDown.Value = "10";
            app.PassbandNoteDropDown.Value = "A4";

            % Initial visibility
            app.PassbandNoteDropDown.Visible = true;
            app.PassbandNoteDropDownLabel.Visible = true;
            app.CutoffFrequencyPairDropDown.Visible = false;
            app.CutoffFrequencyPairDropDownLabel.Visible = false;

            pairs = cell(1, numel(app.note_names)-1);
            for i = 1:numel(app.note_names)-1
                pairs{i} = sprintf('%s & %s', app.note_names{i}, app.note_names{i+1});
            end
            app.CutoffFrequencyPairDropDown.Items = pairs;
            app.CutoffFrequencyPairDropDown.Value = 'F4 & G4';
        end

        % Button pushed function: LoadAudioFileButton
        function LoadAudioFileButtonPushed(app, event)
            app.file_name = "C_Major_Scale_2_unfiltered.wav";
            [x,Fs] = audioread(app.file_name);

            if size(x,2) > 1
                x = mean(x, 2);
            end
            x = x(:);

            app.x = x; 
            app.Fs = Fs;
            N = length(app.x);
            app.t = (0:N-1) / app.Fs;

            total_duration = N / app.Fs;
            note_duration = total_duration / 8;

            app.SamplingFrequencyFsEditField.Value = sprintf('%.0f', app.Fs);
            app.TotalDurationEditField.Value = sprintf('%.2f', total_duration);
            app.NoteDurationEditField.Value = sprintf('%.2f', note_duration);

            plot(app.OriginalSignalAxes,app.t,app.x); grid(app.OriginalSignalAxes,'on');
            xlabel(app.OriginalSignalAxes, 'Time (s)'); ylabel(app.OriginalSignalAxes, 'Amplitude');
            title(app.OriginalSignalAxes, 'Original Signal');

            N_fft = 2 ^ nextpow2(N);
            w = hann(N);
            X = fftshift(fft(app.x .* w, N_fft));
            f_fft = (-N_fft/2 : N_fft/2-1) * (app.Fs / N_fft);
            app.ref = max(abs(X));

            plot(app.OriginalSpectrumAxes, f_fft, abs(X)/app.ref); grid(app.OriginalSpectrumAxes, 'on');
            xlabel(app.OriginalSpectrumAxes, 'Frequency (Hz)'); ylabel(app.OriginalSpectrumAxes, 'Magnitude');
            title(app.OriginalSpectrumAxes, 'Original Spectrum');
            xlim(app.OriginalSpectrumAxes, [-2000 2000]);
        end

        % Value changed function: FilterTypeDropDown
        function FilterTypeDropDownValueChanged(app, event)
            selection = app.FilterTypeDropDown.Value;
            
            switch selection
                case "Band-Pass Filter"
                    % Show "Passband Note" only
                    app.PassbandNoteDropDown.Visible = true;
                    app.PassbandNoteDropDownLabel.Visible = true;
                    app.CutoffFrequencyPairDropDown.Visible = false;
                    app.CutoffFrequencyPairDropDownLabel.Visible = false;
                
                case {"Low-Pass Filter", "High-Pass Filter"}
                    % Show "Cutoff Frequency Pair" only
                    app.PassbandNoteDropDown.Visible = false;
                    app.PassbandNoteDropDownLabel.Visible = false;
                    app.CutoffFrequencyPairDropDown.Visible = true;
                    app.CutoffFrequencyPairDropDownLabel.Visible = true;
            end
        end

        % Button pushed function: ApplyFilterButton
        function ApplyFilterButtonPushed(app, event)
            % Making sure the audio is loaded
            if isempty(app.x) || isempty(app.Fs)
                uialert(app.UIFigure, "Please load the audio first.", "No Audio");
                return;
            end
            
            % Reading Filter Order value
            order = str2double(app.FilterOrderDropDown.Value);
            if isnan(order) || order < 1
                uialert(app.UIFigure, 'Invalid filter order!','Error');
                return;
            end

            % Estimeting fundamental freq for each note
            if isempty(app.f0)
                fmin = 50;
                fmax = 2000;

                number_of_notes = size(app.note_segments,1);
                f0_local = zeros(number_of_notes,1);

                for i = 1:number_of_notes
                    t_start = app.note_segments(i,1);
                    t_end = app.note_segments(i,2);

                    idx = (app.t >= t_start) & (app.t < t_end);
                    x_segment = app.x(idx);
                    x_segment = x_segment - mean(x_segment);

                    N_segment = length(x_segment);
                    if N_segment < 10
                        f0_local(i) = NaN;
                        continue;
                    end

                    f_segment = (-floor(N_segment/2):ceil(N_segment/2)-1) * (app.Fs/N_segment);
                    x_segment = x_segment .* hann(N_segment);
                    X_Segment = fftshift(fft(x_segment));
                    magnitude_spectrum = abs(X_Segment);

                    band = (f_segment >= fmin) & (f_segment <= fmax);
                    magnitude_band = magnitude_spectrum(band);
                    f_band = f_segment(band);

                    [~, peak_index] = max(magnitude_band);
                    f0_local(i) = f_band(peak_index);
                end

                app.f0 = f0_local;
            end

            % Design Filter based on selection
            filter_type = app.FilterTypeDropDown.Value;

            switch filter_type
                case 'Band-Pass Filter'
                    target_note = app.PassbandNoteDropDown.Value;
                    note_index = find(strcmp(app.note_names, target_note), 1);

                    if isempty(note_index) || isnan(app.f0(note_index))
                        uialert(app.UIFigure, "Cannot find f0 for selected note.", "Error");
                        return  
                    end

                    f0_target = app.f0(note_index);
                    delta_f = 15;
                    f_passband = [f0_target - delta_f, f0_target + delta_f];

                    Wn = f_passband / (app.Fs / 2);

                    if Wn(1) <= 0, Wn(1) = 0.001; end
                    if Wn(2) >= 1, Wn(2) = 0.999; end

                    [z,p,k] = butter(order,Wn,'bandpass');
                    [sos,g] = zp2sos(z,p,k);
                    app.y = g * sosfilt(sos,app.x);

                    titleTxt = sprintf('Band-pass: %s (%.1f–%.1f Hz)', target_note, f_passband(1), f_passband(2));

                case 'Low-Pass Filter'
                    pair_str = app.CutoffFrequencyPairDropDown.Value;
                    parts = strsplit(pair_str, '&');
                    note_1 = strtrim(parts{1});
                    note_2 = strtrim(parts{2});

                    i1 = find(strcmp(app.note_names, note_1), 1);
                    i2 = find(strcmp(app.note_names, note_2), 1);

                    if isempty(i1) || isempty(i2) || isnan(app.f0(i1)) || isnan(app.f0(i2))
                        uialert(app.UIFigure, "Cannot compute cutoff from selected pair.", "Error");
                        return;
                    end

                    f_cutoff_lp = (app.f0(i1) + app.f0(i2)) / 2;
                    Wn_lp = f_cutoff_lp / (app.Fs / 2);
                    Wn_lp = min(max(Wn_lp, 0.001), 0.999);

                    [z_lp, p_lp, k_lp] = butter(order,Wn_lp,'low');
                    [sos_lp, g_lp] = zp2sos(z_lp, p_lp, k_lp);
                    app.y = g_lp * sosfilt(sos_lp, app.x);

                    titleTxt = sprintf('Low-pass: fc = %.1f Hz (%s)', f_cutoff_lp, pair_str);

                case 'High-Pass Filter'
                    pair_str = app.CutoffFrequencyPairDropDown.Value;
                    parts = strsplit(pair_str, '&');
                    note_1 = strtrim(parts{1});
                    note_2 = strtrim(parts{2});

                    i1 = find(strcmp(app.note_names, note_1), 1);
                    i2 = find(strcmp(app.note_names, note_2), 1);

                    if isempty(i1) || isempty(i2) || isnan(app.f0(i1)) || isnan(app.f0(i2))
                        uialert(app.UIFigure, "Cannot compute cutoff from selected pair.", "Error");
                        return;
                    end

                    f_cutoff_hp = (app.f0(i1) + app.f0(i2)) / 2;
                    Wn_hp = f_cutoff_hp / (app.Fs / 2);
                    Wn_hp = min(max(Wn_hp, 0.001), 0.999);

                    [z_hp, p_hp, k_hp] = butter(order,Wn_hp,'high');
                    [sos_hp, g_hp] = zp2sos(z_hp, p_hp, k_hp);
                    app.y = g_hp * sosfilt(sos_hp, app.x);

                    titleTxt = sprintf('High-pass: fc = %.1f Hz (%s)', f_cutoff_hp, pair_str);
            end

            app.y = app.y(:);
            app.y = app.y / (max(abs(app.y)) + eps);

            % Plotting filtered time-domain
            cla(app.FilteredSignalAxes);
            plot(app.FilteredSignalAxes, app.t, app.y); grid(app.FilteredSignalAxes, 'on');
            xlabel(app.FilteredSignalAxes, 'Time (s)'); ylabel(app.FilteredSignalAxes, 'Amplitude');
            title(app.FilteredSignalAxes, ['Filtered Signal - ' titleTxt]);

            % Plot Spectrum
            N = length(app.x);
            NFFT = 2 ^nextpow2(N);
            w = hann(N);

            Y = fftshift(fft(app.y .* w, NFFT));
            fFFT = (-NFFT/2 : NFFT/2-1) * (app.Fs / NFFT);

            plot(app.FilteredSpectrumAxes, fFFT, abs(Y)/app.ref); grid(app.FilteredSpectrumAxes, 'on');
            xlabel(app.FilteredSpectrumAxes, 'Frequency (Hz)'); ylabel(app.FilteredSpectrumAxes, 'Magnitude');
            title(app.FilteredSpectrumAxes, 'Filtered Spectrum');
            
            switch filter_type
                case "Band-Pass Filter"
                    xlim(app.FilteredSpectrumAxes,[(f0_target - 300) (f0_target + 300)]);
            
                case "Low-Pass Filter"
                    xlim(app.FilteredSpectrumAxes,[-2*f_cutoff_lp 2*f_cutoff_lp]);
            
                case "High-Pass Filter"
                    xlim(app.FilteredSpectrumAxes,[-2000 2000]);
            end
        end

        % Button pushed function: PlayOriginalAudioButton
        function PlayOriginalAudioButtonPushed(app, event)
            if isempty(app.x) || isempty(app.Fs)
                uialert(app.UIFigure, "Please load the audio first", "No Audio");
                return;
            end;

            app.player_original = audioplayer(app.x, app.Fs);
            play(app.player_original);
        end

        % Button pushed function: PlayFilteredAudioButton
        function PlayFilteredAudioButtonPushed(app, event)
            if isempty(app.x) || isempty(app.Fs)
                uialert(app.UIFigure, "Please load the audio first", "No Audio");
                return;
            end;

            if isempty(app.x) || isempty(app.Fs)
                uialert(app.UIFigure, "Please load the audio first", "No Audio");
                return;
            end;

            app.player_filtered = audioplayer(app.y, app.Fs);
            play(app.player_filtered);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [0.902 0.902 0.902];
            app.UIFigure.Position = [100 100 1092 585];
            app.UIFigure.Name = 'MATLAB App';

            % Create OriginalSignalAxes
            app.OriginalSignalAxes = uiaxes(app.UIFigure);
            title(app.OriginalSignalAxes, 'Original Signal')
            xlabel(app.OriginalSignalAxes, 'Time (s)')
            ylabel(app.OriginalSignalAxes, 'Amplitude')
            zlabel(app.OriginalSignalAxes, 'Z')
            app.OriginalSignalAxes.Position = [398 303 298 189];

            % Create FilteredSignalAxes
            app.FilteredSignalAxes = uiaxes(app.UIFigure);
            title(app.FilteredSignalAxes, 'Filtered Signal')
            xlabel(app.FilteredSignalAxes, 'Time (s)')
            ylabel(app.FilteredSignalAxes, 'Amplitude')
            zlabel(app.FilteredSignalAxes, 'Z')
            app.FilteredSignalAxes.Position = [398 50 298 189];

            % Create OriginalSpectrumAxes
            app.OriginalSpectrumAxes = uiaxes(app.UIFigure);
            title(app.OriginalSpectrumAxes, 'Original Spectrum')
            xlabel(app.OriginalSpectrumAxes, 'Frequency (Hz)')
            ylabel(app.OriginalSpectrumAxes, 'Magnitude')
            zlabel(app.OriginalSpectrumAxes, 'Z')
            app.OriginalSpectrumAxes.Position = [738 303 298 189];

            % Create FilteredSpectrumAxes
            app.FilteredSpectrumAxes = uiaxes(app.UIFigure);
            title(app.FilteredSpectrumAxes, 'Filtered Spectrum')
            xlabel(app.FilteredSpectrumAxes, 'Frequency (Hz)')
            ylabel(app.FilteredSpectrumAxes, 'Magnitude')
            zlabel(app.FilteredSpectrumAxes, 'Z')
            app.FilteredSpectrumAxes.Position = [739 50 298 189];

            % Create EE331FINALASSIGNMENTAPPLICATIONLabel
            app.EE331FINALASSIGNMENTAPPLICATIONLabel = uilabel(app.UIFigure);
            app.EE331FINALASSIGNMENTAPPLICATIONLabel.FontSize = 14;
            app.EE331FINALASSIGNMENTAPPLICATIONLabel.FontWeight = 'bold';
            app.EE331FINALASSIGNMENTAPPLICATIONLabel.Position = [398 541 298 22];
            app.EE331FINALASSIGNMENTAPPLICATIONLabel.Text = 'EE331 FINAL ASSIGNMENT - APPLICATION';

            % Create LoadAudioFileButton
            app.LoadAudioFileButton = uibutton(app.UIFigure, 'push');
            app.LoadAudioFileButton.ButtonPushedFcn = createCallbackFcn(app, @LoadAudioFileButtonPushed, true);
            app.LoadAudioFileButton.Position = [139 491 100 23];
            app.LoadAudioFileButton.Text = 'Load Audio File';

            % Create HzLabel
            app.HzLabel = uilabel(app.UIFigure);
            app.HzLabel.Position = [310 432 25 22];
            app.HzLabel.Text = 'Hz';

            % Create secondsLabel
            app.secondsLabel = uilabel(app.UIFigure);
            app.secondsLabel.Position = [285 392 50 22];
            app.secondsLabel.Text = 'seconds';

            % Create secondsLabel_2
            app.secondsLabel_2 = uilabel(app.UIFigure);
            app.secondsLabel_2.Position = [285 347 50 22];
            app.secondsLabel_2.Text = 'seconds';

            % Create PlayOriginalAudioButton
            app.PlayOriginalAudioButton = uibutton(app.UIFigure, 'push');
            app.PlayOriginalAudioButton.ButtonPushedFcn = createCallbackFcn(app, @PlayOriginalAudioButtonPushed, true);
            app.PlayOriginalAudioButton.Position = [131 90 116 23];
            app.PlayOriginalAudioButton.Text = 'Play Original Audio';

            % Create PlayFilteredAudioButton
            app.PlayFilteredAudioButton = uibutton(app.UIFigure, 'push');
            app.PlayFilteredAudioButton.ButtonPushedFcn = createCallbackFcn(app, @PlayFilteredAudioButtonPushed, true);
            app.PlayFilteredAudioButton.Position = [132 50 115 23];
            app.PlayFilteredAudioButton.Text = 'Play Filtered Audio';

            % Create FilterTypeDropDownLabel
            app.FilterTypeDropDownLabel = uilabel(app.UIFigure);
            app.FilterTypeDropDownLabel.HorizontalAlignment = 'right';
            app.FilterTypeDropDownLabel.Position = [37 282 61 22];
            app.FilterTypeDropDownLabel.Text = 'Filter Type';

            % Create SamplingFrequencyFsEditField
            app.SamplingFrequencyFsEditField = uieditfield(app.UIFigure, 'text');
            app.SamplingFrequencyFsEditField.HorizontalAlignment = 'right';
            app.SamplingFrequencyFsEditField.Position = [192 432 100 22];

            % Create FilterTypeDropDown
            app.FilterTypeDropDown = uidropdown(app.UIFigure);
            app.FilterTypeDropDown.Items = {'Band-Pass Filter', 'Low-Pass Filter', 'High-Pass Filter'};
            app.FilterTypeDropDown.ValueChangedFcn = createCallbackFcn(app, @FilterTypeDropDownValueChanged, true);
            app.FilterTypeDropDown.Position = [113 282 222 22];
            app.FilterTypeDropDown.Value = 'Band-Pass Filter';

            % Create FilterOrderDropDownLabel
            app.FilterOrderDropDownLabel = uilabel(app.UIFigure);
            app.FilterOrderDropDownLabel.HorizontalAlignment = 'right';
            app.FilterOrderDropDownLabel.Position = [36 238 66 22];
            app.FilterOrderDropDownLabel.Text = 'Filter Order';

            % Create TotalDurationEditField
            app.TotalDurationEditField = uieditfield(app.UIFigure, 'text');
            app.TotalDurationEditField.HorizontalAlignment = 'right';
            app.TotalDurationEditField.Position = [131 392 127 22];

            % Create FilterOrderDropDown
            app.FilterOrderDropDown = uidropdown(app.UIFigure);
            app.FilterOrderDropDown.Items = {'4', '6', '8', '10', '12'};
            app.FilterOrderDropDown.Position = [117 238 219 22];
            app.FilterOrderDropDown.Value = '10';

            % Create PassbandNoteDropDownLabel
            app.PassbandNoteDropDownLabel = uilabel(app.UIFigure);
            app.PassbandNoteDropDownLabel.HorizontalAlignment = 'right';
            app.PassbandNoteDropDownLabel.Position = [36 201 87 22];
            app.PassbandNoteDropDownLabel.Text = 'Passband Note';

            % Create NoteDurationEditField
            app.NoteDurationEditField = uieditfield(app.UIFigure, 'text');
            app.NoteDurationEditField.HorizontalAlignment = 'right';
            app.NoteDurationEditField.Position = [131 347 127 22];

            % Create PassbandNoteDropDown
            app.PassbandNoteDropDown = uidropdown(app.UIFigure);
            app.PassbandNoteDropDown.Items = {'C4', 'D4', 'E4', 'F4', 'G4', 'A4', 'B4', 'C5'};
            app.PassbandNoteDropDown.Position = [138 201 198 22];
            app.PassbandNoteDropDown.Value = 'A4';

            % Create ApplyFilterButton
            app.ApplyFilterButton = uibutton(app.UIFigure, 'push');
            app.ApplyFilterButton.ButtonPushedFcn = createCallbackFcn(app, @ApplyFilterButtonPushed, true);
            app.ApplyFilterButton.Position = [139 159 100 23];
            app.ApplyFilterButton.Text = 'Apply Filter';

            % Create CutoffFrequencyPairDropDownLabel
            app.CutoffFrequencyPairDropDownLabel = uilabel(app.UIFigure);
            app.CutoffFrequencyPairDropDownLabel.HorizontalAlignment = 'right';
            app.CutoffFrequencyPairDropDownLabel.Position = [37 201 122 22];
            app.CutoffFrequencyPairDropDownLabel.Text = 'Cutoff Frequency Pair';

            % Create CutoffFrequencyPairDropDown
            app.CutoffFrequencyPairDropDown = uidropdown(app.UIFigure);
            app.CutoffFrequencyPairDropDown.Items = {'C4 & D4', 'D4 & E4', 'E4 & F4', 'F4 & G4', 'G4 & A4', 'A4 & B4', 'B4 & C5'};
            app.CutoffFrequencyPairDropDown.Position = [174 201 161 22];
            app.CutoffFrequencyPairDropDown.Value = 'C4 & D4';

            % Create SamplingFrequencyFsEditFieldLabel
            app.SamplingFrequencyFsEditFieldLabel = uilabel(app.UIFigure);
            app.SamplingFrequencyFsEditFieldLabel.HorizontalAlignment = 'right';
            app.SamplingFrequencyFsEditFieldLabel.Position = [37 432 140 22];
            app.SamplingFrequencyFsEditFieldLabel.Text = 'Sampling Frequency (Fs)';

            % Create TotalDurationEditFieldLabel
            app.TotalDurationEditFieldLabel = uilabel(app.UIFigure);
            app.TotalDurationEditFieldLabel.HorizontalAlignment = 'right';
            app.TotalDurationEditFieldLabel.Position = [37 392 79 22];
            app.TotalDurationEditFieldLabel.Text = 'Total Duration';

            % Create NoteDurationEditFieldLabel
            app.NoteDurationEditFieldLabel = uilabel(app.UIFigure);
            app.NoteDurationEditFieldLabel.HorizontalAlignment = 'right';
            app.NoteDurationEditFieldLabel.Position = [37 347 79 22];
            app.NoteDurationEditFieldLabel.Text = 'Note Duration';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = ZekiyeAyperiTATAR_310206043_app

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end