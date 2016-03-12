%RECONS   ウェーブレットパケット係数の再構成
%   Y = RECONS(T,N,X,S,E) は、サイズ S とエッジ値 E を用いて、データツ
%   リー T のノード N 番目のノードに関連するウェーブレットパケット係数 X%   を再構成します。S 
%   は、N の各上位に関連するデータのサイズを含んでいます。
%   ノード F の子供は、左から右に番号付けされており、[0, ... , ORDER-1]
%   となります。
%   エッジの値は、F と 子供 C の間で、子供の番号です。
%
%   このメソッドは、DTREE メソッドで多重定義されています。

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 18-Oct-96.


%   Copyright 1995-2002 The MathWorks, Inc.
