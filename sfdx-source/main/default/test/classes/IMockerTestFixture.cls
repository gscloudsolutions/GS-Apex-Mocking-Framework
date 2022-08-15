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
 * @description Mocker test fixture interface.
 *
 * @author Leonardo Berardino
 */
public interface IMockerTestFixture {
    void voidMethod();
    void voidMethod(String paramStr, Integer paramInt);
    String stringReturnMethod();
    String stringReturnMethodParams(String paramStr, Integer paramInt);
    String stringReturnMethodParams(Integer paramInt, String paramStr);
    Contact getContact(String email);
    void insertContact(Contact contact);
}
