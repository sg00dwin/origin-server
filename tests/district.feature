@internals
@internals1
@node
Feature: District Configuration
  Scenario: Write district file
    Given a district 1e920055ae134e7c9299f4ad8f12bd14 is active
    Then the file /var/lib/stickshift/district.conf does exist
    And the file /etc/stickshift/district.conf does not exist
    And remove file /var/lib/stickshift/district.conf
