Sys.setlocale("LC_ALL", "en_US.UTF-8")

frf <- function(...)
    rprojroot::find_root_file(..., criterion = ".editorconfig", path = ".")

.source <- function(file, skip = 9, ..., verbose = FALSE) {
    src <- scan(file, what = character(), skip = skip, sep = "\n", quiet = !verbose)
    source(textConnection(paste0(src, collapsed = "\n")), ..., verbose = verbose)
}

label <- function(x)attr(x, "label")
"label<-" <- function(x, ..., value) { attr(x, "label") <- value; x }

filenames <- c(
    data = frf("data", "redcap", "pilot", "CVCCoating_DATA_2025-06-20_1056.csv"),
    rscript = frf("data", "redcap", "pilot", "CVCCoating_R_2025-06-20_1056.r"),
    dictionary = frf("redcap", "pilot", "data_dictionary.csv")
)

data <- read.csv(
    filenames["data"],
    na.strings = c("NA", "")
)

## skip first 9 lines (loading Hmisc package and cleaning the environment)
.source(filenames["rscript"], skip = 9)

d <- data

dic <- read.csv(
    filenames["dictionary"],
    col.names = c(
        "field", "form", "section", "type", "label", "choice", "note",
        "validation_type", "validation_min", "validation_max",
        "is_identifier", "branching", "is_required",
        "alignment", "question_number",
        "matrix_group", "matrix_ranking",
        "annotation"
    )
)

## split dataset into patient/cvc characteristics and visits

## patient characteristics
chrs_forms <- c("mapping", "preop", "lot", "crf", "surgery")
chrs_names <- c("redcap_event_name", dic$field[dic$form %in% chrs_forms])

chrs <- d[!startsWith(d$redcap_event_name, "visite"),]
chrs <- chrs[colnames(chrs) %in% c(chrs_names, paste0(chrs_names, ".factor"))]

## collapse wide data.frame with multiple NA into a single row per patient
.first_non.na <- function(x) {
    which(!is.na(x))
}

chrs <- do.call(rbind, lapply(split(chrs, chrs$record_id), function(pat) {
        non.na <- unlist(lapply(
            pat[!colnames(pat) %in%
                c("record_id", "redcap_event_name", "redcap_event_name.factor")
            ],
            .first_non.na
        ))
        i <- rep(1L, ncol(pat))
        names(i) <- colnames(pat)
        i[names(non.na)] <- non.na
        j  <-  seq_len(ncol(pat))
        as.data.frame(
            mapply(function(i, j)pat[i, j], i = i, j = j, SIMPLIFY = FALSE)
        )
}))
chrs$fallnummer <- NULL
chrs$redcap_event_name <- NULL
chrs$redcap_event_name.factor <- NULL

## visits
vsts_forms <- c("visite", "measurements1", "measurements2")
vsts_names <- c(
    "record_id", "redcap_event_name",
    dic$field[dic$form %in% vsts_forms]
)

vsts <- d[startsWith(d$redcap_event_name, "visite"),]
vsts <- vsts[colnames(vsts) %in% c(vsts_names, paste0(vsts_names, ".factor"))]

vsts$round_id <- as.integer(sub(
    "visite_tag_([0-9]+)_arm_1", "\\1", vsts$redcap_event_name
))
vsts$redcap_event_name <- NULL
vsts$redcap_event_name.factor <- NULL
vsts <- vsts[order(vsts$record_id, vsts$round_id),]

## export
saveRDS(chrs, file = frf("data", "cleaned", "pilot", "characteristics.RDS"))
saveRDS(vsts, file = frf("data", "cleaned", "pilot", "rounds.RDS"))
