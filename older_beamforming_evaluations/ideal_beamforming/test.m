clear all;
clc;
close all;

addpath('../tree_matlab/');
addpath('../export_fig/');

load(['ideal_codebook.mat']);

iterator = cb_tree.depthfirstiterator;

for i=1:1:max(size(iterator))
    cb_tree.get(iterator(i))
end
