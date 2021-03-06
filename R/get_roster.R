####################### Function To Get a Team's Roster ########################
#' Get Team Roster
#'
#' Gets team roster for current season.
#'
#' @param team Team to get roster for

#' @return A data frame of the team's roster
#' @export
get_roster <- function(team, season = current_season) {
  ### Error Testing
  if(is.na(team)) {
    stop("team is missing with no default")
  }
  if(!"ncaahoopR" %in% .packages()) {
    ids <- create_ids_df()
  }
  if(!team %in% ids$team) {
    stop("Invalid team. Please consult the ids data frame for a list of valid teams, using data(ids).")
  }

  if(season == current_season) {
    base_url <- "https://www.espn.com/mens-college-basketball/team/roster/_/id/"
    url <-  paste(base_url, ids$id[ids$team == team], "/", ids$link[ids$team == team], sep = "")
    tmp <- try(XML::readHTMLTable(RCurl::getURL(url)))
    if(class(tmp) == "try-error") {
      warning("Unable to get roster. ESPN is updating CBB files. Check back again soon")
      return(NULL)
    }
    tmp <- as.data.frame(tmp[[1]])
    names(tmp) <- c("number", "name", "position", "height", "weight", "class", "hometown")
    for(i in 1:ncol(tmp)) {
      tmp[,i] <- as.character(tmp[,i])
    }
    tmp$number <- as.numeric(gsub("[^0-9]", "", tmp$name))
    tmp$name <- gsub("[0-9]*", "", tmp$name)
    tmp <- dplyr::arrange(tmp, number)
    return(tmp)
  } else {
    roster <- 
      suppressWarnings(try(readr::read_csv(paste0("https://raw.githubusercontent.com/lbenz730/ncaahoopR_data/master/",
                                                  season,"/rosters/", gsub(" ", "_", team), "_roster.csv"))))
    if(any(class(roster) == 'try-error')) {
      warning('No Roster Available')
      return(NULL) 
    }
                             
    return(roster)
  }
}
