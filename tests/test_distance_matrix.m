NB_TESTS = 3;
TOL_REL = 1e-15;

for test_num = 1:NB_TESTS,
    
    switch test_num
        
        case 1
            nx  = 11;
            ny  = 13;
            dim = 5;
            x   = zeros(nx, dim);
            y   = zeros(ny, dim);
    
        case 2
            nx  = 10;
            ny  = 9;
            dim = 12;
            x   = zeros(nx, dim);
            y   = ones(ny, dim);
            
        case 3
            nx  = 10;
            ny  = nx;
            dim = 7;
            x   = reshape(1:(nx*dim), nx, dim);
            y   = flipud(x);
            
    end
        
    D1 = stk_distance_matrix(x);
    D2 = stk_distance_matrix(x, x);
    D3 = stk_distance_matrix(x, y);
   
    % check that D1 and D2 are the same
    % (after that we don't care about D2 anymore)
    assert(isequal(D1, D2));
    
    % check size of outputs
    assert(isequal(size(D1), [nx, nx]));
    assert(isequal(size(D3), [nx, ny]));
    
    % check for NaNs
    assert(~any(isnan(D1(:))));
    assert(~any(isnan(D3(:))));

    % check for Infs
    assert(~any(isinf(D1(:))));
    assert(~any(isinf(D3(:))));
    
    % check the content of D1
    for i = 1:nx,
        for j = 1:nx,
            d = norm(x(i,:) - x(j,:));
            assert(abs(D1(i,j) - d) <= TOL_REL * d);
        end
    end

    % check the content of D3
    for i = 1:nx,
        for j = 1:ny,
            d = norm(x(i,:) - y(j,:));
            assert(abs(D3(i,j) - d) <= TOL_REL * d);
        end
    end

end
