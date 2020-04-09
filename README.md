# EDH_tidytext
Experiment with Tidytext and EDH dataset


Hello, I am experimenting with the tidytext package in R on the EDH dataset and I have encountered an interesting error I have no idea what to do with. 

1. Clone the repo
2. Run the script ```EDH_tidy.R```
3. I am creating a dataframe from Antonio's dataset from the [https://mplex.github.io/cedhar/EpigraphicNetwork.html](https://mplex.github.io/cedhar/EpigraphicNetwork.html) following the first three commands
4. When I print out the column names (line 19), I get an interesting result - column name does not have a name (NA) and it prevents me from doing the next steps in my script producing an error ```Error: Column 5 must be named. Use .name_repair to specify repair. Run `rlang::last_error()` to see where the error occurred.```
5. I tried whatever I could, however I have no idea how to drop a column with no name. Any ideas?

If yes, please, commit the code here.

Thanks,
P.
