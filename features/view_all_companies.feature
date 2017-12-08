Feature: As a visitor,
  so that I can find companies that can offer me services,
  I want to see all companies

  Background:
    Given the following regions exist:
      | name         |
      | Stockholm    |
      | Västerbotten |

    Given the following kommuns exist:
      | name      |
      | Alingsås  |
      | Bromölla  |

    And the following business categories exist
      | name         |
      | Groomer      |

    Given the following simple companies exist:
      | name      | company_number | email           | region       | kommun  |
      | Company1  | 0000000001     | cmpy1@mail.com  | Stockholm    | Alingsås|
      | Company2  | 0000000002     | cmpy2@mail.com  | Västerbotten | Bromölla|
      | Company3  | 0000000003     | cmpy3@mail.com  | Stockholm    | Alingsås|
      | Company4  | 0000000004     | cmpy4@mail.com  | Stockholm    | Alingsås|
      | Company5  | 0000000005     | cmpy5@mail.com  | Stockholm    | Alingsås|
      | Company6  | 0000000006     | cmpy6@mail.com  | Stockholm    | Alingsås|
      | Company7  | 0000000007     | cmpy7@mail.com  | Stockholm    | Alingsås|
      | Company8  | 0000000008     | cmpy8@mail.com  | Stockholm    | Alingsås|
      | Company9  | 0000000009     | cmpy9@mail.com  | Stockholm    | Alingsås|
      | Company10 | 0000000010     | cmpy10@mail.com | Stockholm    | Alingsås|
      | Company11 | 0000000011     | cmpy11@mail.com | Stockholm    | Alingsås|
      | Company12 | 0000000012     | cmpy12@mail.com | Stockholm    | Alingsås|
      | Company13 | 0000000013     | cmpy13@mail.com | Stockholm    | Alingsås|
      | Company14 | 0000000014     | cmpy13@mail.com | Stockholm    | Alingsås|
      | Company15 | 0000000015     | cmpy13@mail.com | Stockholm    | Alingsås|
      | Company16 | 0000000016     | cmpy13@mail.com | Stockholm    | Alingsås|
      | Company17 | 0000000017     | cmpy13@mail.com | Stockholm    | Alingsås|
      | Company18 | 0000000018     | cmpy13@mail.com | Stockholm    | Alingsås|
      | Company19 | 0000000019     | cmpy13@mail.com | Stockholm    | Alingsås|
      | Company20 | 0000000020     | cmpy13@mail.com | Stockholm    | Alingsås|
      | Company21 | 0000000021     | cmpy13@mail.com | Stockholm    | Alingsås|
      | Company22 | 0000000022     | cmpy13@mail.com | Stockholm    | Alingsås|
      | Company23 | 0000000023     | cmpy13@mail.com | Stockholm    | Alingsås|
      | Company24 | 0000000024     | cmpy13@mail.com | Stockholm    | Alingsås|
      | Company25 | 0000000025     | cmpy13@mail.com | Stockholm    | Alingsås|
      | Company26 | 0000000026     | cmpy13@mail.com | Stockholm    | Alingsås|
      | Company27 | 0000000027     | cmpy13@mail.com | Stockholm    | Alingsås|
      | Company28 | 0000000028     | cmpy13@mail.com | Stockholm    | Alingsås|
      | Company29 | 0000000029     | cmpy13@mail.com | Stockholm    | Alingsås|

    And the following users exists
      | email        | admin | member |
      | a@mutts.com  |       | true   |
      | b@mutts.com  |       | false  |
      | admin@shf.se | true  |        |

    And the following payments exist
      | user_email  | start_date | expire_date | payment_type | status | hips_id | company_number |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 0000000001     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 0000000002     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 0000000003     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 0000000004     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 0000000005     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 0000000006     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 0000000007     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 0000000008     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 0000000009     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 0000000010     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 0000000011     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 0000000012     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 0000000013     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 0000000014     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 0000000015     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 0000000016     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 0000000017     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 0000000018     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 0000000019     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 0000000020     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 0000000021     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 0000000022     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 0000000023     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 0000000024     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 0000000025     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 0000000026     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 0000000027     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 0000000028     |

    And the following simple applications exist:
      | user_email  | company_number | state    | categories |
      | a@mutts.com | 0000000001     | accepted | Groomer    |
      | a@mutts.com | 0000000002     | accepted | Groomer    |
      | a@mutts.com | 0000000003     | accepted | Groomer    |
      | a@mutts.com | 0000000004     | accepted | Groomer    |
      | a@mutts.com | 0000000005     | accepted | Groomer    |
      | a@mutts.com | 0000000006     | accepted | Groomer    |
      | a@mutts.com | 0000000007     | accepted | Groomer    |
      | a@mutts.com | 0000000008     | accepted | Groomer    |
      | a@mutts.com | 0000000009     | accepted | Groomer    |
      | a@mutts.com | 0000000010     | accepted | Groomer    |
      | a@mutts.com | 0000000011     | accepted | Groomer    |
      | a@mutts.com | 0000000012     | accepted | Groomer    |
      | a@mutts.com | 0000000013     | accepted | Groomer    |
      | a@mutts.com | 0000000014     | accepted | Groomer    |
      | a@mutts.com | 0000000015     | accepted | Groomer    |
      | a@mutts.com | 0000000016     | accepted | Groomer    |
      | a@mutts.com | 0000000017     | accepted | Groomer    |
      | a@mutts.com | 0000000018     | accepted | Groomer    |
      | a@mutts.com | 0000000019     | accepted | Groomer    |
      | a@mutts.com | 0000000020     | accepted | Groomer    |
      | a@mutts.com | 0000000021     | accepted | Groomer    |
      | a@mutts.com | 0000000022     | accepted | Groomer    |
      | a@mutts.com | 0000000023     | accepted | Groomer    |
      | a@mutts.com | 0000000024     | accepted | Groomer    |
      | a@mutts.com | 0000000025     | accepted | Groomer    |
      | a@mutts.com | 0000000026     | accepted | Groomer    |
      | a@mutts.com | 0000000027     | accepted | Groomer    |
      | b@mutts.com | 0000000028     | accepted | Groomer    |
      | a@mutts.com | 0000000029     | accepted | Groomer    |


  @selenium @time_adjust
  Scenario: Visitor sees all companies
    Given the date is set to "2017-10-01"
    Given I am Logged out
    And I am on the "landing" page
    Then I should see t("companies.index.h_companies_listed_below")
    And I should see "Company2"
    And I should not see "0000000002"
    And I should see "Company1"
    And I should not see "0000000001"
    And I should not see t("companies.new_company")

  @time_adjust
  Scenario: User sees all the companies
    Given the date is set to "2017-10-01"
    Given I am logged in as "a@mutts.com"
    And I am on the "landing" page
    Then I should see t("companies.index.title")
    And I should see "Company2"
    And I should not see "0000000002"
    And I should see "Company1"
    And I should not see "0000000001"
    And I should not see t("companies.new_company")

  @selenium @time_adjust
  Scenario: Pagination
    Given the date is set to "2017-10-01"
    Given I am Logged out
    And I am on the "landing" page
    Then I should see t("companies.index.h_companies_listed_below")
    And I click on t("toggle.company_search_form.hide")
    And I should see "Company2"
    And I should not see "0000000002"
    And I should see "Company1"
    And I should not see "0000000001"
    And I should see "Company10"
    And I should not see "0000000010"
    And I should not see "Company11"
    Then I click on t("will_paginate.next_label") link
    And I should see "Company11"
    And I should not see "Company10"

  @selenium @time_adjust
  Scenario: I18n translations
    Given the date is set to "2017-10-01"
    Given I am Logged out
    And I set the locale to "sv"
    And I am on the "landing" page
    Then I should see t("companies.index.h_companies_listed_below")
    Then I click on t("toggle.company_search_form.hide") button
    And I should see "Verksamhetslän"
    And I should see "Kategori"
    And I should not see "Region"
    And I should not see "Category"
    Then I click on "change-lang-to-english"
    And I set the locale to "en"
    Then I click on t("toggle.company_search_form.hide") button
    And I wait 1 second
    And I should see "Region"
    And I should see "Category"
    And I should not see "Verksamhetslän"
    And I should not see "Kategori"

  @selenium @time_adjust
  Scenario: Pagination: Set number of items per page
    Given the date is set to "2017-10-01"
    Given I am Logged out
    And I am on the "landing" page
    Then I should see t("companies.index.h_companies_listed_below")
    And I click on t("toggle.company_search_form.hide")
    And "items_count" should have "10" selected
    And I should see "10" companies
    And I should see "Company10"
    And I should not see "Company11"
    And I should not see "Company26"
    Then I select "25" in select list "items_count"
    And I wait for all ajax requests to complete
    Then I should see "25" companies
    And "items_count" should have "25" selected
    And I should see "Company1"
    And I should see "Company2"
    And I should see "Company3"
    And I should see "Company4"
    And I should see "Company5"
    And I should see "Company6"
    And I should see "Company7"
    And I should see "Company8"
    And I should see "Company9"
    And I should see "Company10"
    And I should see "Company11"
    And I should see "Company12"
    And I should see "Company13"
    And I should see "Company14"
    And I should see "Company15"
    And I should see "Company16"
    And I should see "Company17"
    And I should see "Company18"
    And I should see "Company19"
    And I should see "Company20"
    And I should see "Company21"
    And I should see "Company22"
    And I should see "Company23"
    And I should see "Company24"
    And I should see "Company25"
    And I should not see "Company26"
    Then I select "All" in select list "items_count"
    And I wait for all ajax requests to complete
    Then I should see "27" companies
    And I should see "Company26"
    And I should see "Company27"

  @selenium @time_adjust
  Scenario: Companies lacking branding payment or members not shown
    Given the date is set to "2017-10-01"
    Given I am Logged out
    And I am on the "landing" page
    Then I should see t("companies.index.h_companies_listed_below")
    And I click on t("toggle.company_search_form.hide")
    And "items_count" should have "10" selected
    Then I select "All" in select list "items_count"
    And I wait for all ajax requests to complete
    And I should see "Company10"
    And I should see "Company27"
    And I should not see "Company28"
    And I should not see "Company29"
