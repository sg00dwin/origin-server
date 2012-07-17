@runtime
@runtime1
Feature: District Configuration
  Scenario: Write district file
    Given a district 1e920055ae134e7c9299f4ad8f12bd14 is active
    Then the file /var/lib/stickshift/.settings/district.info does exist
    And the file /var/lib/stickshift/.settings/district.info is active for district 1e920055ae134e7c9299f4ad8f12bd14
    And the file /etc/stickshift/district.conf does not exist
    Then remove file /var/lib/stickshift/.settings/district.info
