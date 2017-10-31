
test_that("G matrices", {

    p <- study_parameters(n1 = 3,
                              n2 = 2,
                              n3 = 4,
                              T_end = 10,
                              icc_pre_subject = 0.5,
                              icc_pre_cluster = 0,
                              var_ratio = 0.03,
                              icc_slope = 0.05,
                              dropout = 0,
                              cohend = -0.8)
    d <- simulate_data(p)
    G <- create_G(p, d )

    # all have same dim
    x <- unique(unlist(lapply(G, dim)))
    expect_length(x, 1)
    expect_equal(nrow(d), x)

    ## Unequal
    p <- study_parameters(n1 = 3,
                          n2 = unequal_clusters(2,5,10,50),
                          n3 = 4,
                          T_end = 10,
                          icc_pre_subject = 0.5,
                          icc_pre_cluster = 0,
                          var_ratio = 0.03,
                          icc_slope = 0.05,
                          dropout = 0,
                          cohend = -0.8)
    d <- simulate_data(p)
    G <- create_G(p, d )

    # all have same dim
    x <- unique(unlist(lapply(G, dim)))
    expect_length(x, 1)
    expect_equal(nrow(d), x)

    ## Missing data
    p <- study_parameters(n1 = 3,
                          n2 = unequal_clusters(2,5,10,50),
                          n3 = 4,
                          T_end = 10,
                          icc_pre_subject = 0.5,
                          icc_pre_cluster = 0,
                          var_ratio = 0.03,
                          icc_slope = 0.05,
                          dropout = dropout_weibull(0.4, 0.8),
                          cohend = -0.8)
    d <- simulate_data(p)
    G <- create_G(p, d )

    # all have same dim
    x <- unique(unlist(lapply(G, dim)))
    expect_length(x, 1)
    expect_equal(nrow(d[!is.na(d$y), ]), x)

    ## Partially nested and missing
    p <- study_parameters(n1 = 3,
                          n2 = unequal_clusters(2,5,10,50),
                          n3 = 4,
                          T_end = 10,
                          icc_pre_subject = 0.5,
                          icc_pre_cluster = 0,
                          var_ratio = 0.03,
                          icc_slope = 0.05,
                          dropout = dropout_weibull(0.4, 0.8),
                          partially_nested = TRUE,
                          cohend = -0.8)
    d <- simulate_data(p)
    G <- create_G(p, d )

    # all have same dim
    x <- unique(unlist(lapply(G, dim)))
    expect_length(x, 1)
    expect_equal(nrow(d[!is.na(d$y), ]), x)

})
test_that("make theta", {
    expect_length(make_theta_vec(1.2, 0, 0), 1)
    expect_length(make_theta_vec(1.2, 0, 1.4), 2)
    expect_length(make_theta_vec(1.2, 0.2, 1.4), 3)


    th <- make_theta(c("u0" = 1.2, "u01" = 0, "u1" = 0.5, "v0" = 0, "v01" = 0, "v1" = 0, "sigma" = 2.3))
    expect_length(th, 2)

    th <- make_theta(c("u0" = 1.2, "u01" = 0.5, "u1" = 0.5, "v0" = 1, "v01" = 0, "v1" = 0, "sigma" = 2.3))
    expect_length(th, 4)

    th <- make_theta(c("u0" = 1.2, "u01" = 0.5, "u1" = 0.5, "v0" = 1, "v01" = 0.3, "v1" = 0.3, "sigma" = 2.3))
    expect_length(th, 6)
})

# df
test_that("satterth df 3lvl", {
    object <- study_parameters(n1 = 4,
                                n2 = 5,
                                n3 = 4,
                                T_end = 10,
                                icc_pre_subject = 0.5,
                                icc_pre_cluster = 0.1,
                                cor_subject = -0.5,
                                cor_cluster = -0.4,
                                var_ratio = 0.02,
                                icc_slope = 0.05,
                                dropout = 0,
                                partially_nested = FALSE,
                                cohend = 0.8)


    d <- simulate_data(object)
    f <- lme4::lFormula(formula = create_lmer_formula(object),
                        data = d)

    pc <- setup_power_calc(d, f, object)
    X <- pc$X
    Zt <- pc$Zt
    L0 <- pc$L0
    Lambdat <- pc$Lambdat
    Lind <- pc$Lind
    varb <- varb_func(para = pc$pars, X = X, Zt = Zt, L0 = L0, Lambdat = Lambdat, Lind = Lind)
    Phi <- varb(Lc = diag(4))
    ddf <- get_satterth_df(object, d = d, pars = pc$pars, Lambdat = Lambdat, X = X, Zt = Zt, L0 = L0, Phi = Phi, varb = varb)

    n3 <- get_n3(object)

    expect_equal(ddf, n3$total - 2)
    })
# df
test_that("satterth df 2lvl", {
    object <- study_parameters(n1 = 4,
                               n2 = 5,
                               n3 = 4,
                               T_end = 10,
                               icc_pre_subject = 0.5,
                               icc_pre_cluster = 0,
                               cor_subject = -0.5,
                               cor_cluster = 0,
                               var_ratio = 0.02,
                               icc_slope = 0,
                               dropout = 0,
                               partially_nested = FALSE,
                               cohend = 0.8)


    d <- simulate_data(object)
    f <- lme4::lFormula(formula = create_lmer_formula(object),
                        data = d)

    pc <- setup_power_calc(d, f, object)
    X <- pc$X
    Zt <- pc$Zt
    L0 <- pc$L0
    Lambdat <- pc$Lambdat
    Lind <- pc$Lind
    varb <- varb_func(para = pc$pars, X = X, Zt = Zt, L0 = L0, Lambdat = Lambdat, Lind = Lind)
    Phi <- varb(Lc = diag(4))
    ddf <- get_satterth_df(object, d = d, pars = pc$pars, Lambdat = Lambdat, X = X, Zt = Zt, L0 = L0, Phi = Phi, varb = varb)

    totn <- get_tot_n(object)

    expect_equal(ddf, totn$total - 2)
})

