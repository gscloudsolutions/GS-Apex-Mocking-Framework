/* Copyright (c) 2022 Groundswell Cloud Solutions Inc. - All Rights Reserved
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND "AS AVAILABLE", WITHOUT WARRANTY OF
 * ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
 * DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
 * OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
 * USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

/**
 * @description Mocker test utils tests.
 *
 * @author Leonardo Berardino
 */
@IsTest
@SuppressWarnings('pmd.ApexAssertionsShouldIncludeMessage')
public class MockerUtilsTest {

    @IsTest
    static void generateIdShouldGenerateUniqueSObjectSequenceId() {
        for(Integer i = 1; i <= 20; i++) {
            // When
            Id accountId = MockerUtils.generateId(Account.SObjectType);
            Id contactId = MockerUtils.generateId(Contact.SObjectType);

            // Then
            String expectedId = String.valueOf(i).leftPad(12, '0') + 'AAA';
            System.assertEquals('001' + expectedId, accountId);
            System.assertEquals('003' + expectedId, contactId);
        }
    }

    @IsTest
    static void generateIdShouldGenerateSObjectIdWithTheGivenSequential() {
        // When
        Id accountId = MockerUtils.generateId(Account.SObjectType, 1200);
        Id contactId = MockerUtils.generateId(Contact.SObjectType, 969132);

        // Then
        System.assertEquals('001000000001200AAA', accountId);
        System.assertEquals('003000000969132AAA', contactId);
    }

    @IsTest
    private static void updateObjectStateShouldReturnObjectsWithRelationFieldSet()
    {
        // Given
        Account accountInstance = new Account(
            Id = MockerUtils.generateId(Account.SObjectType),
            Name = 'Test Account',
            NumberOfEmployees = 10
        );

        Date birthdate = Date.today().addYears(-10);
        Contact contact1 = (Contact) MockerUtils.updateObjectState(
            new Contact(), new Map<String, Object>{
                'Id' => MockerUtils.generateId(Contact.SObjectType),
                'Name' => 'Leonardo Berardino',
                'FirstName' => 'Leonardo',
                'Birthdate' => birthdate
            }
        );

        Contact contact2 = new Contact(
            Id = MockerUtils.generateId(Contact.SObjectType),
            FirstName = 'Another',
            LastName = 'Contact',
            Email = 'test@mockingframework.com'
        );

        // When
        Account updatedAccount = (Account) MockerUtils.updateObjectState(
            accountInstance, new Map<String, Object> {
                'Contacts' => new List<Contact> {
                    contact1, contact2
                },
                'Website' => 'https://test.com',
                'Name' => 'New Account Name',
                'NumberOfEmployees' => 99
            }
        );

        // Then
        System.assertEquals(accountInstance.Id, updatedAccount.Id);
        System.assertEquals('New Account Name', updatedAccount.Name);
        System.assertEquals('https://test.com', updatedAccount.Website);
        System.assertEquals(99, updatedAccount.NumberOfEmployees);

        List<Contact> contacts = updatedAccount.Contacts;
        System.assertEquals(2, contacts?.size());

        System.assertEquals('Leonardo', contacts[0].FirstName);
        System.assertEquals('Leonardo Berardino', contacts[0].Name);
        System.assertEquals(birthdate, contacts[0].Birthdate);

        System.assertEquals(contact2.Id, contacts[1].Id);
        System.assertEquals('test@mockingframework.com', contacts[1].Email);
    }

    @IsTest
    private static void updateObjectStateShouldIgnoreInvalidFields()
    {
        // Given
        Account accountInstance = new Account(
            Id = MockerUtils.generateId(Account.SObjectType),
            Name = 'Test Account',
            NumberOfEmployees = 15
        );

        try {
            // When
            Account updatedAccount = (Account) MockerUtils.updateObjectState(
                accountInstance, new Map<String, Object> {
                    'NumberOfEmployees' => 30,
                    'InvalidAccountField' => 'Invalid field value',
                    'Name' => 'New Name'
                }
            );

            // Then
            System.assertEquals(accountInstance.Id, updatedAccount.Id);
            System.assertEquals('New Name', updatedAccount.Name);
            System.assertEquals(30, updatedAccount.NumberOfEmployees);

        } catch (Exception e) {
            System.assert(false, 'The method should not throw an exception: ' + e.getMessage());
        }
    }
}
