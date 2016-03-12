% ISTNODE　 不連続ノードの検出
% R = ISTNODE(T,N) は、ツリー T に属している不連続ノード N に対して、ランク(不連
% 続ノードを左から右方向に番号付けしたもの)を他の場合は0を出力します。
%
% N はノードのインデックスを含む列ベクトル、または、ノードの深さと位置を含む行列
% のいずれかとなります。行列の場合は、N(i,1) は i 番目のノードの深さ、N(i,2) は 
% i 番目のノードの位置をそれぞれ示しています。
%
% ノードは、左から右、上から下へと番号付けされています。ルートとなるインデックス
% は0です。
% 
% 参考： ISNODE, WTREEMGR.



%   Copyright 1995-2002 The MathWorks, Inc.
