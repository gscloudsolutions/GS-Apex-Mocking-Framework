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
 * @description The mocker provider interface
 *
 * @author Leonardo Berardino
 */
public interface IMockerProvider {
    /**
     * @description Enables the stubbing for the current called method without
     *              computing the received parameters values
     *
     * @return The current mock provider instance
     */
    IMockerProvider withAnyValues();

    /**
     * @description  Mocks the current method return value
     *
     * @param mockReturnValue The current method mocked return value
     * @return The current mock provider instance
     */
    IMockerProvider thenReturn(Object mockReturnValue);

    /**
     * @description Mocks the current method exception
     *
     * @param exceptionToThrow The exception that will be thrown when the mock method will called
     * @return The current mock provider instance
     */
    IMockerProvider thenThrow(Exception exceptionToThrow);

    /**
     * @description Creates an assertion constraint indicating that the current mocked method
     *              only can be called once. This assertion constraint will be verified
     *              during the assertion phase
     *
     * @return The current mock provider instance
     */
    IMockerProvider shouldBeCalledOnce();

    /**
     * @description Creates an assertion constraint indicating that the current mocked method
     *              only can be called the given times. This assertion constraint will be verified
     *              during the assertion phase
     *
     * @param times The number of calls constraint
     * @return The current mock provider instance
     */
    IMockerProvider shouldBeCalled(Integer times);

    /**
     * @description Creates an assertion constraint indicating that the current mocked method
     *              cannot be called. This assertion constraint will be verified during the
     *              assertion phase
     *
     * @return The current mock provider instance
     */
    IMockerProvider shouldNeverBeCalled();

    /**
     * @description Creates an assertion constraint indicating that the current mocked method
     *              only can be called between the min and max given times. This assertion
     *              constraint will be verified during the assertion phase
     *
     * @param minTimes The minimum number of calls constraint
     * @param maxTimes The maximum number of calls constraint
     * @return The current mock provider instance
     */
    IMockerProvider shouldBeCalledBetween(Integer minTimes, Integer maxTimes);

    /**
     * @description Asserts this mock statistics using the constraints created on
     *              the stubbing phase
     *
     * @param throwAnException When True, instead of use System.assert for the
     *        assertion, it will throw a MockException if the assertion fails
     */
    void assert(Boolean throwAnException);

    /**
     * @description Gets the method executing recording data
     *
     * @return The method executing recording data
     */
    Mocker.MethodRecorder getMethodRecorder();
}
