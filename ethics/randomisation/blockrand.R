####
## Block randomisation for CVC-Coating
##
## TODO:
## 1. Adapt seed (and store it save and secure til the end of the analysis).
## 2. Run whole script or better use `make randomise`.
## 3. Print and store "randomisation_table_unblinded.csv" and
## "randomisation_table_groups.csv" files at a save place.
## 4. Send the "randomisation_cards.pdf" for printing and enveloping.
####

####
## TODO: change the following seed to whatever you like
set.seed(795278274)

####
## TODO: if you don't want to clone the whole repository and using guix
## replace the root path here, e.g. `root <- "."` or `root <- getwd()`.
# root <- getwd()
root <- rprojroot::find_root_file(
    "ethics", "randomisation",
    criterion = rprojroot::is_git_root
)

####
## WARNING: don't change anything below this line
####


####
## Randomisation
####
library("blockrand")

.blockrand <- function(
    ## n per stratum
    n = 10,
    ## treatment levels (2 different CVC)
    levels = c(
        "EU-22854-N (CVC 4-Lumen ARROWg+ard Blue Protection)",
        "EU-12854-N (CVC 4-Lumen)"
    ),
    ## variable block sizes are `block.sizes * 2`
    block.sizes = 1:3,
    ...
)blockrand(n = n, levels = levels, block.sizes = block.sizes, ...)

study <- do.call(
    rbind,
    list(
        .blockrand(
            id.prefix = "WL", block.prefix = "WL", stratum = "weiblich / Leber"
        ),
        .blockrand(
            id.prefix = "WP", block.prefix = "WP", stratum = "weiblich / Pankreas"
        ),
        .blockrand(
            id.prefix = "WG", block.prefix = "WG", stratum = "weiblich / Gastrointestinal"
        ),
        .blockrand(
            id.prefix = "ML", block.prefix = "ML", stratum = "männlich / Leber"
        ),
        .blockrand(
            id.prefix = "MP", block.prefix = "MP", stratum = "männlich / Pankreas"
        ),
        .blockrand(
            id.prefix = "MG", block.prefix = "MG", stratum = "männlich / Gastrointestinal"
        )
    )
)

# simplified treatment group names
study$treatmentname <-
    ifelse(grepl("Blue", study$treatment), "blau", "gelb")

## random group name for blinded per-protocol analysis
study$group <- sample(c("A", "B"))[as.integer(study$treatment)]

####
## Save randomisation results
####

write.csv(
    study[c("id", "group")],
    file = file.path(root, "randomisation_table_groups.csv"),
    row.names = FALSE
)

write.csv(
    study,
    file = file.path(root, "randomisation_table_unblinded.csv"),
    row.names = FALSE
)

####
## Plot cards for envelops
####

cex <- 1.5
study_name <- "CVC-Coating"
group_col <- c("#FDAE61FF", "#3288BDFF")
strat_col <- c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3", "#FF7F00", "#A65628")

names(group_col) <- levels(study$treatment)
names(strat_col) <- unique(study$stratum)

pdf(
    file = file.path(root, "randomisation_cards.pdf"),
    height = 29.7 / 2.54,
    width =  21 / 2.54,
    paper = "a4",
    onefile = TRUE
)
par(mfrow = c(3, 1), mai = c(0, 0, 0, 0), xaxs = "i", yaxs = "i")

plot.new()
sh <- strheight("Iy") * cex * 1.5
pid <- "Patient*in-ID: "
swpid <- strwidth(pid)
par(new = TRUE)

for (i in seq_len(nrow(study))) {
    plot.new()
    ## address field
    suppressWarnings(text(
        x = c(rep(0.06, 3), 0.06 + cex * swpid, 0.06, 0.07),
        y = 0.45 - c(0, 1, 2, 2, 3, 5.5) * sh,
        labels = c(
            paste0("Studie: ", study_name),
            "Studienleitung: Sebastian Gibb (Tel. 5870)",
            pid, as.expression(bquote(bold(.(study$id[i])))),
            "Stratum:",
            as.expression(bquote(bold(.(
                sub(" / ", "\n", study$stratum[i])
            ))))
        ),
        col = c(rep("black", 5), strat_col[study$stratum[i]]),
        adj = c(0, 0.5),
        cex = c(rep(cex, 5), cex * 1.2)
    ))
    ## main field
    text(
        x = c(0.5, 0.51 + swpid, 0.5, 0.5, 0.5),
        y = 0.9 - c(0, 0, 1.2, 2.5, 4) * sh,
        labels = c(
            pid, as.expression(bquote(bold(.(study$id[i])))),
            "Gruppe / Auszuwählender ZVK:",
            as.expression(bquote(bold(.(as.character(study$treatment[i]))))),
            as.expression(bquote(bold(.(as.character(study$treatmentname[i])))))
        ),
        col = c(rep("black", 3), rep(group_col[study$treatment[i]], 2)),
        cex = c(rep(cex, 3), cex * 1.2, cex * 1.2)
    )
    abline(h = 0:1, col = "darkgrey", lty = "dashed")
}
dev.off()
