% Explanation 
% The specified variable appears inside a parfor loop within different indexing expressions. 
% Because the indices are inconsistent across the uses of the array created by the parfor loop, 
% MATLAB sends the entire array to each worker, resulting in high data communication overhead. For example, 
% the following code elicits this message for c, because there are two different indexing expressions for it:

% % c=foo();
% % parfor i = 1:N
% %     a(i) = c(i,1);
% %     b(i) = c(i,2);
% % end

% When the indices are the same for all instances of the indexed variable, the variable is classified as sliced,
% and MATLAB sends only the required elements to the workers for each iteration of the parfor loop.
% Suggested Action 
% In some cases, there is no way to avoid this message, and therefore you should suppress it, 
% as described in Adjust Code Analyzer Message Indicators and Messages
% However, in most cases, you can use additional variables to avoid this problem. 
% For example, in the following code, x and y are sliced and do not elicit the message.
% In effect, the temporary variables make it clear to MATLAB which data to ship to the workers:

% % c = foo();
% % x = c(:,1);
% % y = c(:,2);
% % parfor i = 1:N
% %     a(i) = x(i);
% %     b(i) = y(i);
% % end 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
