%% Initialize.m
% Initializes the environments for starting 60 Ghz Testbed Experiments

%% Clear the MATLAB Workspace
clear;
clc;
close all;

%% Set the PATH environments
addpath(genpath('M_Code_Reference'));
addpath(genpath('tcp_udp_ip'));
addpath(genpath('AutoControl'));

%% Display MoD
% Display the message of the day
disp('**********************************************************************');
disp('* 60 GHz Evalation Testbench                                         *');
disp('**********************************************************************');
disp('Starting experiments ...');
timenow=int8(clock);
disp(['current time is ' num2str(timenow(4)) ':' num2str(timenow(5)) ':' num2str(timenow(6))]);

%% Set up constants
