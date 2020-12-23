
////////////////////////////////////////////////////////////////////////////////
/////////////////Longitudinal-IOP with EU-SILC - Auxiliary code/////////////////
////////////////////////////////////////////////////////////////////////////////

if `year' == 07 {
    local countries Austria Belgium Denmark Estonia Finland ///
        France Greece Iceland Ireland Italy Luxembourg Norway ///
        Portugal Spain Sweden // 15 countries
}
if `year' == 08 {
    local countries Austria Belgium Cyprus ///
        CzechRepublic Denmark Estonia Finland France ///
        Greece Hungary Iceland Ireland Italy Latvia Lithuania ///
        Luxembourg Netherlands Norway Poland Portugal ///
        Slovakia Slovenia Spain Sweden ///
        UnitedKingdom // 25 countries
}
if `year' == 09 {
    local countries Austria Belgium Bulgaria Cyprus ///
        CzechRepublic Denmark Estonia Finland France ///
        Greece Hungary Iceland Ireland Italy Latvia Lithuania ///
        Luxembourg Malta Netherlands Norway Poland Portugal ///
        Slovakia Slovenia Spain Sweden ///
        UnitedKingdom // 27 countries
}
if `year' >= 10 & `year' <= 11 {
    local countries Austria Belgium Bulgaria Cyprus ///
        CzechRepublic Denmark Estonia Finland France ///
        Greece Hungary Iceland Italy Latvia Lithuania ///
        Luxembourg Malta Netherlands Norway Poland Portugal ///
        Romania Slovakia Slovenia Spain Sweden ///
        UnitedKingdom // 27 countries
}
if `year' == 12 {
    local countries Austria Belgium Bulgaria Cyprus ///
        CzechRepublic Denmark Estonia Finland France ///
        Greece Hungary Iceland Ireland Italy Latvia Lithuania ///
        Luxembourg Malta Netherlands Norway Poland Portugal ///
        Romania Slovakia Slovenia Spain Sweden ///
        UnitedKingdom // 28 countries
}
if `year' == 13 {
    local countries Austria Belgium Bulgaria Croatia Cyprus ///
        CzechRepublic Denmark Estonia Finland France ///
        Greece Hungary Iceland Ireland Italy Latvia Lithuania ///
        Luxembourg Malta Netherlands Norway Poland Portugal ///
        Romania Slovakia Slovenia Spain Sweden ///
        UnitedKingdom // 29 countries
}
if `year' >= 14 & `year' <= 15 {
    local countries Austria Belgium Bulgaria Croatia Cyprus ///
        CzechRepublic Denmark Estonia Finland France ///
        Greece Hungary Iceland Ireland Italy Latvia Lithuania ///
        Luxembourg Malta Netherlands Norway Poland Portugal ///
        Romania Slovakia Slovenia Spain Sweden Switzerland ///
        UnitedKingdom // 30 countries
}
if `year' == 16 {
    local countries Austria Belgium Bulgaria Croatia Cyprus ///
        CzechRepublic Denmark Estonia Finland France ///
        Greece Hungary Iceland Italy Latvia Lithuania ///
        Luxembourg Malta Netherlands Norway Poland Portugal ///
        Romania Slovakia Slovenia Spain Sweden Switzerland ///
        UnitedKingdom // 29 countries
}
if `year' == 17 {
    local countries Austria Belgium Bulgaria Croatia Cyprus ///
        CzechRepublic Denmark Estonia Finland France ///
        Greece Hungary Italy Latvia Lithuania ///
        Luxembourg Malta Netherlands Norway Poland Portugal ///
        Romania Slovenia Spain Sweden // 25 countries
}
