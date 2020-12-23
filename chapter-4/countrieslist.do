
////////////////////////////////////////////////////////////////////////////////
///////////////////////IOPK with EU-SILC - Auxiliary code///////////////////////
////////////////////////////////////////////////////////////////////////////////

if `year' == 04 {
    local countries Austria Belgium Denmark Estonia Finland ///
        France Greece Iceland Ireland Italy Luxembourg Norway ///
        Portugal Spain Sweden // 15 countries
}
if `year' >= 05 & `year' <= 06 {
    local countries Austria Belgium Cyprus CzechRepublic Denmark ///
        Estonia Finland France Germany Greece Hungary Iceland ///
        Ireland Italy Latvia Lithuania Luxembourg Netherlands ///
        Norway Poland Portugal Slovakia Slovenia Spain Sweden ///
        UnitedKingdom // 26 countries
}
if `year' >= 07 & `year' <= 09 {
    local countries Austria Belgium Bulgaria Cyprus ///
        CzechRepublic Denmark Estonia Finland France Germany ///
        Greece Hungary Iceland Ireland Italy Latvia Lithuania ///
        Luxembourg Malta Netherlands Norway Poland Portugal ///
        Romania Slovakia Slovenia Spain Sweden Switzerland ///
        UnitedKingdom // 30 countries
}
if `year' >= 10 & `year' <= 16 {
    local countries Austria Belgium Bulgaria Croatia Cyprus ///
        CzechRepublic Denmark Estonia Finland France Germany ///
        Greece Hungary Iceland Ireland Italy Latvia Lithuania ///
        Luxembourg Malta Netherlands Norway Poland Portugal ///
        Romania Slovakia Slovenia Spain Sweden Switzerland ///
        UnitedKingdom // 31 countries
}
if `year' == 17 {
    local countries Austria Belgium Bulgaria Croatia Cyprus ///
        CzechRepublic Denmark Estonia Finland France Germany ///
        Greece Hungary Ireland Italy Latvia Lithuania ///
        Luxembourg Malta Netherlands Norway Poland Portugal ///
        Romania Slovakia Slovenia Spain Sweden ///
        UnitedKingdom // 29 countries
        // No 2017: Iceland Switzerland
}
