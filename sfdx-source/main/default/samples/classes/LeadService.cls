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
 * @description Lead Service Sample Class
 *
 * @author Leonardo Berardino
 */
public with sharing class LeadService {

    @TestVisible
    private static DmlHelper dmlHelper = new DmlHelper();
    @TestVisible
    private static LeadSelector leadSelector = new LeadSelector();

    public String getLeadName(Id leadId) {
        List<Lead> leads = leadSelector.getLeadsById(new Set<Id> { leadId });
        return leads.isEmpty() ? null : leads[0].Name;
    }

    public void createLeads(List<String> names, String source) {
        List<Lead> leads = new List<Lead>();
        for(String name : names) {
            leads.add(createLead(name, source));
        }
        dmlHelper.insertObjects(leads);
    }

    public void upsertLeadsNames(Map<Id, String> newNames) {
        Map<Id, Lead> leads = new Map<Id, Lead>(leadSelector.getLeadsById(newNames.keySet()));
        List<Lead> leadsToUpsert = new List<Lead>();

        for(Id leadId : newNames.keySet()) {
            Lead lead = leads.get(leadId);
            String newName = newNames.get(leadId);

            String leadSource = lead == null ? 'System' : lead.LeadSource;
            Lead leadToUpdate = createLead(newName, leadSource);

            if(lead != null) {
                leadToUpdate.Id = lead.Id;
            }
            leadsToUpsert.add(leadToUpdate);
        }

        dmlHelper.upsertObjects(leadsToUpsert);
    }

    private Lead createLead(String name, String source) {
        String[] names = name.split(' ', 2);
        String lastName = names.size() > 1 ? names[1] : names[0];
        String firstName = names.size() > 1 ? names[0] : null;
        return new Lead(
            FirstName = firstName,
            LastName = lastName,
            LeadSource = source
        );
    }

}
