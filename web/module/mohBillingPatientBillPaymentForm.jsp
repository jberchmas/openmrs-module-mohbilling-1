<%@ include file="/WEB-INF/template/include.jsp"%>
<%@ include file="/WEB-INF/template/header.jsp"%>
<openmrs:htmlInclude file="/scripts/calendar/calendar.js" />
<openmrs:htmlInclude file="/moduleResources/@MODULE_ID@/scripts/jquery-1.3.2.js" />
<%@ taglib prefix="billingtag" uri="/WEB-INF/view/module/@MODULE_ID@/taglibs/billingtag.tld" %>

<%@ include file="templates/mohBillingLocalHeader.jsp"%>
<%@ include file="templates/mohBillingBillHeader.jsp"%>

 <script type="text/javascript">
        $(function () {
            var total;
            var checked = $('.items').click(function (e) {
                calculateSum();
            });

            function calculateSum() {
                var $checked = $('.items:checked');
                total = 0.0;
                $checked.each(function () {
                    total += parseFloat($(this).val());
                    
                });
                $('#tot').text("Your Payable  Is: " + total.toFixed(2));
            }
        });
    </script>
    
<script type="text/javascript">
$(document).ready(function(){
	//first the balance is hidden until deposit checkbox is checked
	$('.depositPayment').hide();
	//$('.cashPayment').hide();
	$('#depositCheckbox').attr('checked', false);
	$('#depositCheckbox').click(function() {
		  if ($(this).is(":checked")) {
                $(".depositPayment").show();
                $('.cashPayment').hide();
                $('#cashCheckbox').attr('checked', false);
            } 
		  else{
			  $(".depositPayment").hide();
			  $('#cashCheckbox').attr('checked', false);
			  }
	});	
	
	$('#cashCheckbox').click(function() {
		if ($(this).is(":checked")) {
            $(".cashPayment").show();
            $('.depositPayment').hide();
            $('#depositCheckbox').attr('checked', false);
        } 
		else{
			$(".cashPayment").hide();
			 $('#depositCheckbox').attr('checked', false);
			}
		});	
});
</script>

 
<h2>Patient Bill Payment</h2>

<%@ include file="templates/mohBillingInsurancePolicySummaryForm.jsp"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<c:set var="insurancePolicy" value="${consommation.beneficiary.insurancePolicy}"/>
<c:set var="globalBill" value="${consommation.globalBill}"/>

<div style="text-align: right;">

<a href="billing.form?insurancePolicyId=${insurancePolicy.insurancePolicyId}&ipCardNumber=${insurancePolicy.insuranceCardNo}&globalBillId=${globalBill.globalBillId}">Add consommation</a></div>

<br/>
<div class="box">
	<form action="patientBillPayment.form?consommationId=${consommation.consommationId}&ipCardNumber=${param.ipCardNumber}&save=true" method="post" id="formSaveBillPayment">
		<table width="99%">
			<tr>
				<th class="columnHeader"></th>
				<th class="columnHeader">Service</td>
				<th class="columnHeader center">Qty</td>
				<th class="columnHeader right">Unit Price (Rwf)</td>
				<th class="columnHeader right">Price (Rwf)</td>
				<th class="columnHeader right">Insurance : ${insurancePolicy.insurance.currentRate.rate} %</td>
				<th class="columnHeader right">Patient : ${100-insurancePolicy.insurance.currentRate.rate} %</td>
				<th></th>
			</tr>
			<c:if test="${empty consommation.billItems}"><tr><td colspan="7"><center>No consommation found !</center></td></tr></c:if>
			<c:set var="totalBillInsurance" value="0"/>
			<c:set var="totalBillPatient" value="0"/>
			<c:forEach items="${consommation.billItems}" var="billItem" varStatus="status">
			<c:set var="service" value="${billItem.service.facilityServicePrice}"/>
			<c:set var="fieldName" value="item-${consommation.consommationId}-${billItem.patientServiceBillId}"/>
			 <c:if test="${not billItem.voided}">
				<tr>
					<td class="rowValue ${(status.count%2!=0)?'even':''}">${status.count}.</td>
					<td class="rowValue ${(status.count%2!=0)?'even':''}">${service.name}</td>
					<td class="rowValue center ${(status.count%2!=0)?'even':''}">${billItem.quantity}</td>
					<td class="rowValue right ${(status.count%2!=0)?'even':''}">${billItem.unitPrice}</td>
					<td class="rowValue right ${(status.count%2!=0)?'even':''}"><fmt:formatNumber value="${billItem.unitPrice*billItem.quantity}" type="number" pattern="#.##"/></td>
					<td class="rowValue right ${(status.count%2!=0)?'even':''}">					  
						<fmt:formatNumber value="${((billItem.unitPrice*billItem.quantity)*insurancePolicy.insurance.currentRate.rate)/100}" type="number" pattern="#.##"/>
						<c:set var="totalBillInsurance" value="${totalBillInsurance+(((billItem.unitPrice*billItem.quantity)*insurancePolicy.insurance.currentRate.rate)/100)}"/>
					</td>
					<td class="rowValue right ${(status.count%2!=0)?'even':''}">							
						 <fmt:formatNumber value="${((billItem.unitPrice*billItem.quantity)*(100-insurancePolicy.insurance.currentRate.rate))/100}" type="number" pattern="#.##"/>
						 <c:set var="totalBillPatient" value="${totalBillPatient+(((billItem.unitPrice*billItem.quantity)*(100-insurancePolicy.insurance.currentRate.rate))/100)}"/>
					</td>							
					<td><input name="${fieldName}" class="items" value="${(((billItem.unitPrice*billItem.quantity)*(100-insurancePolicy.insurance.currentRate.rate))/100)}" type="checkbox"></td>
				</tr>
				</c:if>
			</c:forEach>		   
			<tr>			   
				<td colspan="4"> <p align="center" style="color: red; " id="tot"></p></td>
				<td><div style="text-align: right;"><b>Total : </b></div></td>
				<td><div class="amount"><fmt:formatNumber value="${totalBillInsurance}" type="number" pattern="#.##"/></div></td>
				<td><div class="amount"><fmt:formatNumber value="${totalBillPatient}" type="number" pattern="#.##"/></div></td>
			</tr>			
			<tr>
				<td colspan="7"><hr/></td>
			</tr>
			<tr style="font-size: 1em">
				<td><b>Collector</b></td>
				<td colspan="2"><openmrs_tag:userField formFieldName="billCollector" initialValue="${authUser.userId}"/></td>
				<td colspan="2"></td>
				<td><div style="text-align: right;"><b>Amount Paid</b></div></td>
				<td><div class="amount">${billingtag:amountPaidForPatientBill(consommation.consommationId)}</div></td>
			    
				
			</tr>
			<tr>
				<td><b>Received Date</b></td>
				<td colspan="2"><input type="text" autocomplete="off" name="dateBillReceived" size="11" onclick="showCalendar(this);" value="<openmrs:formatDate date='${todayDate}' type="string"/>"/></td>
				<td colspan="2"></td>
				<td><div style="text-align: right;"><b>Paid by Third Part</b></div></td>
				<td><div class="amount">${consommation.thirdPartyBill.amount}</div></td>				
			</tr>
			<tr>
				<td></td>
				<td colspan="2"></td>
				<td colspan="2"></td>
				<td><div style="text-align: right;"><b>Rest</b></div></td>
				<td><div class="amount">${billingtag:amountNotPaidForPatientBill(consommation.consommationId)}</div></td>				
			</tr>
		
			<tr>
				<td><b>Pay with deposit</b></td>
				<td><input type="checkbox" id="depositCheckbox" name="depositPayment" value="depositPayment"> </td>
				<td class="depositPayment">
				<table><tr>
				<td><b>Deducted Amount </b><input type="text" id="deductedAmount" name="deductedAmount" size="11" class="numbers"/></td>
				<td> <b>Balance </b><input type="text" disabled="disabled" name="balance" value="${patientAccount.balance }" size="11" class="numbers"/></td>	
				</tr>
				</table>
				</td>				
			</tr>
			<tr>
			  <td><b>Pay with cash</b></td>
			  <td><input type="checkbox" id="cashCheckbox" name="cashPayment" value="cashPayment" checked="checked" > </td>
			  <td class="cashPayment">
			  <table><tr>
			  <td><b>Received Cash</b><input type="text" autocomplete="off" name="receivedCash" size="11" class="numbers" value=""/></td>
			  </tr>
			  </table>
			  </td>				
			</tr>			
			<tr>
				<td colspan="7"><hr/></td>
			</tr>			
			<tr style="font-size: 1.2em">
				<openmrs:hasPrivilege privilege="Edit Bill">
					<td colspan="2"><input type="submit"  value="Confirm Payment" style="min-width: 200px;" onclick="check()"/></td>
				</openmrs:hasPrivilege>
			 <td colspan="3"></td>
			</tr>	
			<c:if test="${payment}!=null">	
			<td colspan="2"><div style="text-align: right;"><a href="printPDFBillPayment.form?consommationId=${consommation.consommationId}&paymentId=${payment.paymentId}">Print Bill</a></div></td>	
			</c:if>
		</table>
	</form>
</div>
<br/>
	<c:set var="payments" value="${consommation.patientBill.payments}" scope="request"/>
<c:import url="mohBillingPaymentHistory.jsp" />

<%@ include file="/WEB-INF/template/footer.jsp"%>