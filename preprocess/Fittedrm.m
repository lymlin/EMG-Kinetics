function nY = Fittedrm(W)
%[fitresult, gof] = createFit(Ts, W)
%CREATEFIT(TS,W)
%  创建一个拟合。
% 
%  要进行 '无标题拟合 1' 拟合的数据:
%      X 输入: Ts
%      Y 输出: W
%  输出:
%      fitresult: 表示拟合的拟合对象。
%      gof: 带有拟合优度信息的结构体。
%
%  另请参阅 FIT, CFIT, SFIT.

%  由 MATLAB 于 29-Mar-2022 02:49:41 自动生成

Ts = -getPreTimeInms:1/getFs*1000:getObserveWin;

%% 拟合: '无标题拟合 1'。
[xData, yData] = prepareCurveData(Ts',W);
% 设置 fittype 和选项。
ft = fittype( 'poly4' );
excludedPoints = (xData < 0) | (xData > 150);
opts = fitoptions( 'Method', 'LinearLeastSquares' );
opts.Exclude = excludedPoints;

% 对数据进行模型拟合。
[fitresult, gof] = fit(xData, yData, ft, opts );
%fY = feval(fitresult,xData);
W(Ts < 0) = 1e-3.*smooth(W(find(Ts < 0)));
Ind2 = find(Ts>=0);
W(Ind2) = W(Ind2) - feval(fitresult,Ts(Ind2));
%figure;plot(W)
Y = W(1:find(Ts == 150));
%figure;plot(Ts(1:find(Ts == 150)),Y)

%T1 = Ts(1:find(Ts == 150));
%figure;plot(T1,smooth(T1,Y,0.1,'loess'))
%figure;plot(Ts(1:find(Ts == 150)),Y);hold on;plot(Ts(1:find(Ts == 150)),smoothdata(Y,'gaussian',20));hold off
nY = smoothdata(Y,'gaussian',20);
nY = [nY;W(Ts > 150)];
% 绘制数据拟合图。
       % figure( 'Name', '无标题拟合 1' );
       % h = plot( fitresult, xData, yData, excludedPoints );
        %legend( h, 'W vs. Ts', '已排除 W vs. Ts', '无标题拟合 1', 'Location', 'NorthEast', 'Interpreter', 'none' );
        % 为坐标区加标签
        %xlabel( 'Ts', 'Interpreter', 'none' );
        %ylabel( 'W', 'Interpreter', 'none' );
        %grid on

end

