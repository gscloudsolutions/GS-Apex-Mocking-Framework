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
 * @description Mocker test fixture class.
 *
 * @author Leonardo Berardino
 */
@IsTest
@SuppressWarnings('pmd')
public class MockerTestFixture implements IMockerTestFixture {
    public void voidMethod() {}

    public void voidMethod(String paramStr, Integer paramInt) {}

    public String stringReturnMethod() {
        return 'stringReturnMethod return';
    }

    public String stringReturnMethodParams(String paramStr, Integer paramInt) {
        return 'stringReturnMethod(String, Integer) return';
    }

    public String stringReturnMethodParams(Integer paramInt, String paramStr) {
        return 'stringReturnMethod(Integer, String) return';
    }

    public Contact getContact(String email) {
        return new Contact(FirstName = 'Default contact', Email = email);
    }

    public void insertContact(Contact contact) {
        insert contact;
    }
}
