
# README

Overview
--------

This is Stata code to replicate all results, graphs and tables of my doctoral thesis, entitled "Issues on the measurement of Opportunity Inequality". Three main files run all of the code to generate the data for 14 figures and 15 tables in the dissertation. The replicator should expect the code to run for about 10 to 15 days.

Data Availability and Provenance Statements
----------------------------

### Statement about Rights

- [x] I certify that the author of the manuscript have legitimate access to and permission to use the data used in this manuscript. 

### Summary of Availability

- [x] **No data can be made** publicly available.

### Details on the Data Source

All the results in the dissertation use confidential microdata from the [European Union Statistics on Income and Living Conditions (EU-SILC)](https://ec.europa.eu/eurostat/web/microdata/european-union-statistics-on-income-and-living-conditions). To gain access to the microdata, follow the directions [here](https://ec.europa.eu/eurostat/documents/203647/771732/How_to_apply_for_microdata_access.pdf/82d98876-75e5-49f3-950a-d56cec15b896) on how to write a proposal for access to the data.
You must request the following datasets in your proposal, which correspond to the 2019 Revision:
1. Cross-sectional files, 2004 to 2017
2. Longitudinal files, 2004 to 2017

Computational requirements
---------------------------

### Software Requirements

- Stata (code was last run with version 14.2) with the following user-written programs:

  - [`iop`](https://www.stata-journal.com/article.html?article=st0361) (version 2.6)
  - [`fastgini`](https://ideas.repec.org/c/boc/bocode/s456814.html) (version 1.0)
  - [`esttab`](https://www.stata-journal.com/article.html?article=st0085_1) (version 2.0.9)
  - `grc1leg2` (version 1.2)

### Memory and Runtime Requirements

Approximate time needed to reproduce the analyses on a standard (CURRENT YEAR) desktop machine:

- [ ] 10-60 minutes
- [ ] 1-8 hours
- [ ] 8-24 hours
- [ ] 1-3 days
- [ ] 3-10 days
- [x] 10-15 days
- [ ] > 15 days
- [ ] Not feasible to run on a desktop machine, as described below.

The code was last run on a **4-core Intel-based desktop machine with 32 GB of RAM and Manjaro 20.2 GNOME Linux 5.9**. Computation took 336 hours. 

Description of programs/code
----------------------------

Each chapter has a `main` file that runs all other `do` files for that chapter in the appropriate order. All results from each chapter of the thesis are obtained by running these `main` files.

### License for Code

The code is licensed under a GPL-3.0 License. See [LICENSE.txt](LICENSE.txt) for details.

Instructions to Replicators
---------------------------

Clone the repository or download the `do` files to your computer and proceed in the following manner:

- Install the required user-written programs listed above, under "Software requirements".
- Edit `chapter-3-main` to adjust the default paths.
- Run `chapter-3-main`.
- Once the program concludes, repeat the process with `chapter-4-main` and `chapter-5-main`.
- Respect the order of the chapters and observe additional instructions contained in the `main` files.

List of tables and figures
---------------------------

The provided code reproduces all figures in the dissertation, plus all tables but two, which belong to the introductory chapter 2 and are merely illustrative.

## Acknowledgements

The content of this page draws from "[A template README for social science replication packages](https://social-science-data-editors.github.io/template_README/)", which follows best practices as defined by a number of data editors at social science journals.

