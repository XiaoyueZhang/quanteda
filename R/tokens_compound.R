#' convert token sequences into compound tokens
#' 
#' Replace multi-token sequences with a multi-word, or "compound" token.  The
#' resulting compound tokens will represent a phrase or multi-word expression, 
#' concatenated with  \code{concatenator} (by default, the "\code{_}" character)
#' to form a single "token".  This ensures that the sequences will be processed
#' subsequently as single tokens, for instance in constructing a \link{dfm}.
#' @param x an input \link{tokens} object
#' @param sequences a set of pattern matches to identify token sequences, one of a:
#' \itemize{
#'   \item{list of characters}{consisting of a list of token patterns, separated by white space};
#'   \item{\link{dictionary} object}{;}
#'   \item{\link{collocations} object.}{}
#' }
#' @param concatenator the concatenation character that will connect the words 
#'   making up the multi-word sequences.  The default \code{_} is highly 
#'   recommended since it will not be removed during normal cleaning and 
#'   tokenization (while nearly all other punctuation characters, at least those
#'   in the Unicode punctuation class [P] will be removed.
#' @param valuetype how to interpret word matching patterns: \code{"glob"} for 
#'   "glob"-style wildcarding, \code{fixed} for words as 
#'   is; \code{"regex"} for regular expressions
#' @param case_insensitive logical; if \code{TRUE}, ignore case when matching
#' @return a \link{tokens} object in which the token sequences matching the patterns 
#' in \code{sequences} have been replaced by  compound "tokens" joined by the concatenator
#' @export
#' @author Kenneth Benoit (R) and Kohei Watanabe (C++)
#' @examples
#' mytexts <- c("The new law included a capital gains tax, and an inheritance tax.",
#'              "New York City has raised taxes: an income tax and inheritance taxes.")
#' mytoks <- tokens(mytexts, removePunct = TRUE)
#' 
#' # for lists of sequence elements
#' myseqs <- list(c("tax"), c("income", "tax"), c("capital", "gains", "tax"), c("inheritance", "tax"))
#' (cw <- tokens_compound(mytoks, myseqs))
#' dfm(cw)
#' 
#' # when used as a dictionary for dfm creation
#' mydict <- dictionary(list(tax=c("tax", "income tax", "capital gains tax", "inheritance tax")))
#' (cw2 <- tokens_compound(mytoks, mydict))
#' 
#' # to pick up "taxes" in the second text, set valuetype = "regex"
#' (cw3 <- tokens_compound(mytoks, mydict, valuetype = "regex"))
#' 
#' # dictionaries w/glob matches
#' myDict <- dictionary(list(negative = c("bad* word*", "negative", "awful text"),
#'                           postiive = c("good stuff", "like? th??")))
#' toks <- tokens(c(txt1 = "I liked this, when we can use bad words, in awful text.",
#'                  txt2 = "Some damn good stuff, like the text, she likes that too."))
#' tokens_compound(toks, myDict)
#'
#' # with collocations
#' collocs <- collocations("capital gains taxes are worse than inheritance taxes", size = 2:3)
#' toks <- tokens("The new law included capital gains taxes and inheritance taxes.")
#' tokens_compound(toks, collocs)
tokens_compound <- function(x, sequences,
                    concatenator = "_", valuetype = c("glob", "regex", "fixed"),
                    case_insensitive = TRUE) {
    UseMethod("tokens_compound")
}


#' @rdname tokens_compound
#' @noRd
#' @importFrom data.table setorder data.table
#' @export
tokens_compound.tokens <- function(x, sequences,
                   concatenator = "_", valuetype = c("glob", "regex", "fixed"),
                   case_insensitive = TRUE) {
    verbose <- FALSE
        
    # check that sequences is a list
    if (!is.list(sequences))
        stop("sequences must be a list of character elements, dictionary, or collocations")

    # convert collocations sequences into a simple list of characters
    if (is.collocations(sequences)) {
        word1 <- word2 <- word3 <- NULL
        # sort by word3 so that trigrams will be processed before bigrams
        data.table::setorder(sequences, -word3, word1)
        # concatenate the words                               
        word123 <- sequences[, list(word1, word2, word3)]
        sequences <- unlist(apply(word123, 1, list), recursive = FALSE)
        sequences <- lapply(sequences, unname)
        sequences <- lapply(sequences, function(y) y[y != ""])
    }
    
    # convert dictionaries into a list of phrase sequences 
    if (is.dictionary(sequences)) {
        sequences <- strsplit(unlist(sequences, use.names = FALSE), " ")
    }

    # make sure the list is all character
    if (!all(sapply(sequences, is.character, USE.NAMES = FALSE))) 
        stop("sequences must be a list of character elements or a dictionary")
    
    valuetype <- match.arg(valuetype)
    
    # Initialize
    seqs <- as.list(sequences)
    seqs <- seqs[lengths(seqs) > 1] # drop single words
    types <- types(x)
    
    # Convert to regular expressions, then to fixed
    if (valuetype %in% c("glob"))
        seqs <- lapply(seqs, glob2rx)
    if (valuetype %in% c("glob", "regex")) {
        # Generates all possible patterns of keys
        seqs_fixed <- regex2fixed4(seqs, index(types, valuetype, case_insensitive))
    } else {
        seqs_fixed <- seqs
    }
    if (verbose) message(sprintf('Join %d pairs of tokens', length(seqs_fixed)))
    if (length(seqs_fixed) == 0) return(x) # do nothing
    
    seqs_id <- lapply(seqs_fixed, fmatch, table=types)
    seqs_type <- sapply(seqs_fixed, paste0, collapse = concatenator)
    ids <- fmatch(seqs_type, types)
    res <- qatd_cpp_replace_int_list(x, seqs_id, ids, length(types) + 1)
    
    # Select and types to add
    ids_new <- res$id_new
    names(ids_new) <- seqs_type
    ids_new <- sort(ids_new)
    types <- c(types, names(ids_new[length(types) < ids_new]))
    
    tokens <- res$text
    attributes(tokens) <- attributes(x)
    types(tokens) <- types
    
    return(tokens)
}


#' @noRd
#' @rdname tokens_compound
#' @export
tokens_compound.tokenizedTexts <- function(x, sequences, 
                                           concatenator = "_", valuetype = c("glob", "regex", "fixed"),
                                           case_insensitive = TRUE) {
    as.tokenizedTexts(tokens_compound(as.tokens(x), sequences = sequences, 
                                      concatenator = concatenator, valuetype = valuetype,
                                      case_insensitive = TRUE))
}


