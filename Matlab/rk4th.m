function [T, X] =  rk4th(dydx, ti, tf, X0, h)
    T = ti:h:tf ;
    X = zeros(length(X0), length(T));
    X(:,1)= X0;
    for i = 1:(length(T)-1)
        k_1 = dydx(T(i), X(:,i));
        k_2 = dydx(T(i) + 0.5 * h, X(:,i) + 0.5 * h * k_1);
        k_3 = dydx((T(i) + 0.5 * h), (X(:,i) + 0.5 * h * k_2));
        k_4 = dydx((T(i) + h), (X(:,i) + k_3 * h));
        X(:,i+1) = X(:,i) + (1/6)*(k_1 + 2 * k_2 + 2 * k_3 + k_4) * h;
    end
end
