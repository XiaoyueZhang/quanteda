context('test selectFeatures.R')

test_that("test that selectFeatures (new) is same as selectFeaturesOLD", {
    toks <- tokenize(c("This IS UPPER And Lower case",
                       "THIS is ALL CAPS aNd sand"))
    fixedFeats <- c("and", "is")
    
    expect_identical(
        selectFeatures(toks, fixedFeats, selection = "remove", valuetype = "fixed", case_insensitive = TRUE),
        selectFeaturesOLD(toks, fixedFeats, selection = "remove", case_insensitive = TRUE),
    )

    expect_identical(
        selectFeatures(toks, fixedFeats, selection = "remove", valuetype = "fixed", case_insensitive = FALSE),
        selectFeaturesOLD(toks, fixedFeats, selection = "remove", case_insensitive = FALSE),
    )

    regexFeats <- "is$|and"
    
    expect_identical(
        selectFeatures(toks, regexFeats, selection = "remove", valuetype = "regex", case_insensitive = TRUE),
        selectFeaturesOLD(toks, regexFeats, selection = "remove", valuetype = "regex", case_insensitive = TRUE),
    )

    expect_identical(
        selectFeatures(toks, regexFeats, selection = "remove", valuetype = "regex", case_insensitive = FALSE),
        selectFeaturesOLD(toks, regexFeats, selection = "remove", valuetype = "regex", case_insensitive = FALSE),
    )

    globFeats <- c("*is*", "?and")
    
    expect_identical(
        selectFeatures(toks, regexFeats, selection = "remove", valuetype = "glob", case_insensitive = TRUE),
        selectFeaturesOLD(toks, regexFeats, selection = "remove", valuetype = "glob", case_insensitive = TRUE),
    )
    
    expect_identical(
        selectFeatures(toks, regexFeats, selection = "remove", valuetype = "glob", case_insensitive = FALSE),
        selectFeaturesOLD(toks, regexFeats, selection = "remove", valuetype = "glob", case_insensitive = FALSE),
    )
    
    
})


test_that("test that selectFeatures.tokens is same as selectFeatures.tokenizedTexts", {
    txt <- c(doc1 = "This IS UPPER And Lower case",
             doc2 = "THIS is ALL CAPS aNd sand")
    toks <- tokenize(txt)
    toksh <- tokens(txt)

    fixedFeats <- c("and", "is")
    
    expect_identical(
        selectFeatures(toks, fixedFeats, selection = "remove", valuetype = "fixed", case_insensitive = TRUE),
        as.tokenizedTexts(selectFeatures(toksh, fixedFeats, selection = "remove", valuetype = "fixed", case_insensitive = TRUE))
    )
    
    expect_identical(
        selectFeatures(toks, fixedFeats, selection = "remove", valuetype = "fixed", case_insensitive = FALSE),
        as.tokenizedTexts(selectFeatures(toksh, fixedFeats, selection = "remove", valuetype = "fixed", case_insensitive = FALSE))
    )
    
    regexFeats <- c("is$", "and")
    
    expect_identical(
        selectFeatures(toks, regexFeats, selection = "remove", valuetype = "regex", case_insensitive = TRUE),
        as.tokenizedTexts(selectFeatures(toksh, regexFeats, selection = "remove", valuetype = "regex", case_insensitive = TRUE))
    )
    
    expect_identical(
        selectFeatures(toks, regexFeats, selection = "remove", valuetype = "regex", case_insensitive = FALSE),
        as.tokenizedTexts(selectFeatures(toksh, regexFeats, selection = "remove", valuetype = "regex", case_insensitive = FALSE))
    )
    
    globFeats <- c("*is*", "?and")
    
    expect_identical(
        selectFeatures(toks, globFeats, selection = "remove", valuetype = "glob", case_insensitive = TRUE),
        as.tokenizedTexts(selectFeatures(toksh, globFeats, selection = "remove", valuetype = "glob", case_insensitive = TRUE))
    )
    
    expect_identical(
        selectFeatures(toks, globFeats, selection = "remove", valuetype = "glob", case_insensitive = FALSE),
        as.tokenizedTexts(selectFeatures(toksh, globFeats, selection = "remove", valuetype = "glob", case_insensitive = FALSE))
    )
    
    
})


