/* Copyright (c) 2022 Groundswell Cloud Solutions Inc. - All Rights Reserved
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND "AS AVAILABLE", WITHOUT WARRANTY OF
 * ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
 * DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
 * OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
 * USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

/**
 * @description Lead Service Sample Test
 *
 * @author Leonardo Berardino
 */
@IsTest
public class LeadServiceTest {

    @IsTest
    static void testGetLeadNameShouldReturnLeadNameWhenValidId() {
        // Given
        Id validId = MockerUtils.generateId(Lead.SObjectType);
        Id invalidId = MockerUtils.generateId(Lead.SObjectType, 999);

        Lead expectedLead = (Lead) MockerUtils.updateObjectState(
            new Lead(
                Id = validId,
                LeadSource = 'Test'
            ),
            new Map<String, Object> {
                'Name' => 'Leonardo Berardino'
            }
        );

        // Starting the stubbing phase
        Mocker mocker = Mocker.startStubbing();

        LeadSelector leadSelectorMock  = (LeadSelector) mocker.mock(LeadSelector.class);

        mocker.when(leadSelectorMock.getLeadsById(new Set<Id> { validId }))
            .thenReturn(new List<Lead> { expectedLead });

        mocker.when(leadSelectorMock.getLeadsById(null))
            .withAnyValues()
            .thenReturn(new List<Lead>());

        // Going to the execution phase
        mocker.stopStubbing();

        // Replacing the real instance by the mocked one
        LeadService.leadSelector = leadSelectorMock;

        // When
        String leadNameValidId = new LeadService().getLeadName(validId);
        String leadNameInvalidId = new LeadService().getLeadName(invalidId);

        // Then
        System.assertEquals('Leonardo Berardino', leadNameValidId);
        System.assertEquals(null, leadNameInvalidId);
    }

    @IsTest
    static void testUpsertLeadsNamesShouldUpdateExistingLeads() {
        // Given
        Id leadId = MockerUtils.generateId(Lead.SObjectType);
        Id invalidId = MockerUtils.generateId(Lead.SObjectType);
        Lead databaseLead = (Lead) MockerUtils.updateObjectState(
            new Lead(
                Id = leadId,
                LeadSource = 'Test'
            ),
            new Map<String, Object> {
                'Name' => 'Leonardo Berardino'
            }
        );

        // Starting the stubbing phase
        Mocker mocker = Mocker.startStubbing();

        DmlHelper dmlHelperMock  = (DmlHelper) mocker.mock(DmlHelper.class);
        dmlHelperMock.upsertObjects(null);
        Mocker.MethodRecorder upsertObjectsRec = mocker.when()
            .withAnyValues()
            .getMethodRecorder();

        LeadSelector leadSelectorMock  = (LeadSelector) mocker.mock(LeadSelector.class);
        mocker.when(leadSelectorMock.getLeadsById(null))
            .withAnyValues()
            .thenReturn(new List<Lead> { databaseLead });

        // Going to the execution phase
        mocker.stopStubbing();

        // Replacing the real instances by the mocked ones
        LeadService.leadSelector = leadSelectorMock;
        LeadService.dmlHelper = dmlHelperMock;

        // When
        new LeadService().upsertLeadsNames(new Map<Id, String> {
            leadId => 'John Smith',
            invalidId => 'Elliot Brown'
        });

        // Then
        System.assertEquals(1, upsertObjectsRec.getCallsCount());

        List<Lead> leads = (List<Lead>) upsertObjectsRec
            .getCallRecording(1)
            .getArgument('objects');

        System.assertNotEquals(null, leads);
        System.assertEquals(2, leads.size());

        System.assertEquals(leadId, leads[0].Id);
        System.assertEquals('John', leads[0].FirstName);
        System.assertEquals('Smith', leads[0].LastName);

        System.assertEquals(null, leads[1].Id);
        System.assertEquals('Elliot', leads[1].FirstName);
        System.assertEquals('Brown', leads[1].LastName);
    }

    @IsTest
    static void testUpsertLeadsNamesShouldThrowExceptionWhenFails() {
        // Given
        Id leadId = MockerUtils.generateId(Lead.SObjectType);

        // Starting the stubbing phase
        Mocker mocker = Mocker.startStubbing();

        DmlHelper dmlHelperMock  = (DmlHelper) mocker.mock(DmlHelper.class);
        dmlHelperMock.upsertObjects(null);
        Mocker.MethodRecorder upsertObjectsRec = mocker.when()
            .withAnyValues()
            .getMethodRecorder();

        LeadSelector leadSelectorMock  = (LeadSelector) mocker.mock(LeadSelector.class);
        mocker.when(leadSelectorMock.getLeadsById(null))
            .withAnyValues()
            .thenThrow(new DmlException('Database error'));

        // Going to the execution phase
        mocker.stopStubbing();

        // Replacing the real instances by the mocked ones
        LeadService.leadSelector = leadSelectorMock;
        LeadService.dmlHelper = dmlHelperMock;

        try {
            // When
            new LeadService().upsertLeadsNames(new Map<Id, String> {
                leadId => 'John Smith'
            });

        } catch (Exception e) {
            // Then
            System.assert(e instanceof DmlException, 'Exception should be an DMLException');
            System.assertEquals(0, upsertObjectsRec.getCallsCount());
        }
    }
}
