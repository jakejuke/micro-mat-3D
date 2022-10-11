function h = plotHillert( x,varargin )
%plotHillert Plots the Hillert grain size distribution
%
%   h = plotHillert( x,varargin ) plots the Hillert distribution of grain
%   sizes for 0 <= x < 2. Optional plot parameters can be included. Returns
%   the figure handle h. (For 3D case)
%   
%   Jules Dake
%   27 Jul 2016
%   

u = 8*x/9;
f = (8/9)*(2*exp(1))^3 .* (3*u)./(2-u).^5 .* exp(6./(u-2));

h = plot(x,f,varargin{:});
xlabel('$R/\langle R\rangle$','Interpreter','Latex');
ylabel('frequency')

end

