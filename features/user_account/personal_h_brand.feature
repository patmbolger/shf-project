Feature: As an user I want to be able to view and download my personal h-brand
  So that I can use it in multiple ways to confirm my association with the organization
  And also show my business services that have been certified by the organization

  Background:
    Given the following users exist
      | email         | admin | member | membership_number | first_name | last_name |
      | emma@mutts.se |       | true   | 1001              | Emma       | Edmond    |

    Given the following business categories exist
      | name  | description                     |
      | groom | grooming dogs from head to tail |
      | rehab | physical rehabilitation         |

    Given the following applications exist:
      | user_email    | company_number | categories   | state    |
      | emma@mutts.se | 5562252998     | rehab, groom | accepted |

    Given the date is set to "2017-11-01"

    Given the following payments exist
      | user_email    | start_date | expire_date | payment_type | status | hips_id |
      | emma@mutts.se | 2017-10-1  | 2017-12-31  | member_fee   | betald | none    |

  @time_adjust
  Scenario: User downloads personal-h-brand image
    Given I am logged in as "emma@mutts.se"
    And I am on the "landing" page for "emma@mutts.se"
    And I should see t("hello", name: 'Emma')
    Then I click on the t("menus.nav.users.your_account") link
    And I should see t("users.show.personal_h_brand")
    And I should see "groom, rehab"
    And I click on the second t("users.show.download_image") link
    Then I should get a downloaded image with the filename "personal-h-brand.jpeg"
