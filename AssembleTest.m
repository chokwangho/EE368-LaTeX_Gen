% Tests 10 test equations
load EquationTestData
for i = 1:length(equations)
    A = fn_assemble_eq(equations(i));
    disp([num2str(i) ' => ' A])
end