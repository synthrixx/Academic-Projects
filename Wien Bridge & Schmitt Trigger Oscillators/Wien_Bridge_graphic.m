clc; close all; clear all;

R1 = 10 * power(10,3);
C1 = 1 * power(10,-9);
C2 = 1 * power(10,-9);
R2 = 10 : 0.5 : 15;

f_cal = zeros(size(R2));

for i = 1:length(R2)
    f_cal(i) = 1 / (2 * pi * sqrt(R1 * R2(i) * power(10,3) * C1 * C2) * power(10,3));
end

f_meas = [15.110 14.616 14.231 13.861 13.508 13.172 12.853 12.550 12.262 11.989 11.728];

figure;
plot(R2,f_meas,'bs-','LineWidth',1.2); hold on;
plot(R2,f_cal,'r.--','LineWidth',1.2); hold off;
xlabel('R2 (kohm)'); ylabel('Frequency (kHz)');
title('Osciallation frequency: Measured vs Calculated');
legend('Measured','Calculated');
grid on;

for k = 1:length(R2)
    err(k) = 100 * (f_cal(k) - f_meas(k)) / f_cal(k);
    fprintf('%% Error for R2 = %.3f : %.3f\n', R2(k), err(k));
end