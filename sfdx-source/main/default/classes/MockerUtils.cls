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
 * @description Mocker test utilities
 *
 * @author Leonardo Berardino
 */
@IsTest
public class MockerUtils {

    /**
     * @description Stores the used Ids by object type
     */
    private static final Map<SObjectType, Integer> ID_SEQUENCE_MAP = new Map<SObjectType, Integer>();

    /**
     * @description Generates a fake Salesforce Id for the given SObject type
     * @param sobjectType The SObject type for the Id
     * @return The fake Id for the give SObject type
     */
    public static Id generateId(SObjectType sobjectType) {
        Integer sequence = ID_SEQUENCE_MAP.get(sobjectType);
        if (sequence == null) {
            sequence = 0;
        }
        ID_SEQUENCE_MAP.put(sobjectType, ++sequence);
        return generateId(sobjectType, sequence);
    }

    /**
     * @description Generates a fake Salesforce Id for the given SObject type with
     *              the given sequence
     * @param sobjectType The SObject type for the Id
     * @param sequence The Id Sequence
     * @return The fake Id for the give SObject type
     */
    public static Id generateId(SObjectType sobjectType, Integer sequence) {
        String keyPrefix = sobjectType.getDescribe().getKeyPrefix();
        String idValue = String.valueOf(sequence++).leftPad(12, '0');
        return Id.valueOf(keyPrefix + idValue);
    }

    /**
     * @description Updates the SObject internal state with the given data. This method
     * @param instance The object instance
     * @param fieldDataMap The fields data to update (field name => data)
     *
     * @return A new object instance updated with the given data
     */
    public static SObject updateObjectState(SObject instance, Map<String, Object> fieldDataMap) {
        String objectJSON = serializeObjectUpdatingFields(instance, fieldDataMap);
        Type objectType = Type.forName(String.valueOf(instance.getSObjectType()));
        return (SObject) JSON.deserialize(objectJSON, objectType);
    }

    /**
     * @description Serializes the object updating the given fields
     * @param instance The object instance
     * @param fieldDataMap The fields data to update (field name => data)
     *
     * @return The object serialized in the JSON format
     */
    private static String serializeObjectUpdatingFields(SObject instance, Map<String, Object> fieldDataMap) {
        List<String> serializedFields = new List<String>();
        for(String fieldName : fieldDataMap.keySet()) {
            String serializedField = serializeField(fieldName, fieldDataMap.get(fieldName));
            if(String.isNotBlank(serializedField)) {
                serializedFields.add(serializedField);
            }
        }

        String objectJSON = JSON.serialize(instance);
        if(serializedFields.isEmpty()) {
            return objectJSON;
        }

        return String.format(
            '{0},{1}\'}\'',
            new String[] {
                objectJSON.left(objectJSON.length() - 1),
                String.join(serializedFields, ',')
            }
        );
    }

    /**
     * @description Serializes the given field on the JSON format
     * @param fieldName The field name
     * @param value The field value
     *
     * @return The field serialized in the JSON format or null if it is not possible to serialize it
     */
    private static String serializeField(String fieldName, Object value) {
        try {
            Boolean isList = value instanceof List<Object>;
            if(isList) {
                List<Object> listValue = (List<Object>) value;
                String results = JSON.serialize(value);
                return String.format(
                    '"{0}":\'{\'"done":true,"records":{1},"totalSize":{2}\'}\'',
                    new String[] { fieldName, results, String.valueOf(listValue.size())}
                );
            }

            return String.format(
                '"{0}":{1}', new String[] { fieldName, JSON.serialize(value) }
            );

        } catch (Exception e) {
            System.debug(LoggingLevel.WARN, 'Error serializing the field ' + fieldName + ' => ' + e.getMessage());
            return null;
        }
    }
}
