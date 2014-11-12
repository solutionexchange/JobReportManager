function JobReportManager(RqlConnectorObj, TreeType, TreeGuid, TreeDescent, TreeParentGuid) {
	var ThisClass = this;

	this.RqlConnectorObj = RqlConnectorObj;
	
	this.TemplateNavbar = '#template-navbar';
	this.TemplateReports = '#template-reports';
	this.TemplateProcessing = '#template-processing';
	this.TemplateReport = '#template-report';
	
	ThisClass.UpdateArea(this.TemplateNavbar, {});
	
	this.GetReports(TreeType, TreeGuid, TreeDescent, TreeParentGuid);
	
	var ReportsContainer = $(this.TemplateReports).attr('data-container');
	var NavbarContainer = $(this.TemplateNavbar).attr('data-container');
	$(NavbarContainer).on('click', '.select-none', function(){
		$(ReportsContainer).find('input').prop('checked', false);
	});
	
	$(NavbarContainer).on('click', '.select-all', function(){
		$(ReportsContainer).find('input').prop('checked', true);
	});
	
	$(NavbarContainer).on('click', '.delete-reports', function(){
		var ReportGuidsArray = [];
		$(ReportsContainer).find('input:checked').each(function(){
			ReportGuidsArray.push($(this).attr('name'));
		});
		
		ThisClass.DeleteSelectedReports(ReportGuidsArray);
	});
	
	$(ReportsContainer).on('click', '.btn', function(){
		var ReportGuid = $(this).attr('id');
		var ReportName = $(this).text();
		ThisClass.ViewReport(ReportGuid, ReportName);
	});
}

JobReportManager.prototype.GetReports = function(TreeType, TreeGuid, TreeDescent, TreeParentGuid) {
	var ThisClass = this;
	
	var RqlXml = '<TREESEGMENT type="' + TreeType + '" action="load" guid="' + TreeGuid + '" descent="' + TreeDescent + '" parentguid="' + TreeParentGuid + '"/>';
	
	this.RqlConnectorObj.SendRql(RqlXml, false, function(data){
		var regHeadlinePageIDPattern = '(.+?)\\(PageID:.([0-9]+?)\\)';
		var regHeadlinePageID = new RegExp(regHeadlinePageIDPattern,'');
		var regStartTimeStatusPattern = 'Start:(.+)/Status:(.+)';
		var regStartTimeStatus = new RegExp(regStartTimeStatusPattern,'');
		var Reports = [];
		
		$(data).find('SEGMENT').each(function(){
			var Headline;
			var PageID;
			var StartTime;
			var Status;
			var match;
		
			var ReportGuid = $(this).attr('guid');
		
			var HeadlinePageID = $(this).attr('value');
			match = regHeadlinePageID.exec(HeadlinePageID);
			
			if(match != null)
			{
				Headline = match[1];
				PageID = match[2];
			}
			else
			{
				Headline = HeadlinePageID;
				PageID = '-1';
			}

			var StartTimeStatus = $(this).attr('col2value');
			match = regStartTimeStatus.exec(StartTimeStatus);
			
			if(match != null)
			{
				StartTime = ThisClass.FormatDateTime(match[1]);
				Status = match[2];
			}
			
			var ReportObj = {guid: ReportGuid, pageid: PageID, headline: Headline, starttime: StartTime, status: Status};
			
			Reports.push(ReportObj);
		});
		
		ThisClass.UpdateArea(ThisClass.TemplateReports ,{reports: Reports});
		
		var ReportsContainer = $(ThisClass.TemplateReports).attr('data-container');
		$(ReportsContainer).find('table').tablesorter({
			// sort on the 2nd column, order dsc 
			sortList: [[2,1]],
			headers: { 0: { sorter: false } } 
		}); 
	});
}
		
JobReportManager.prototype.FormatDateTime = function(InputDateTime) {
	var ReturnDateTime = Date.parse(InputDateTime);
	
	if(!ReturnDateTime)
	{
		return '';
	}
	
	return ReturnDateTime.toString('yyyy/MM/dd hh:mm tt');
}

JobReportManager.prototype.ViewReport = function(ReportGuid, ReportName) {
	var ReportContainer = $(this.TemplateReport).attr('data-container');

	this.UpdateArea(this.TemplateReport, {name: ReportName});
	
	$(ReportContainer).find('.modal').modal('show');

	var RqlXml = '<PROJECT><EXPORTREPORT guid="' + ReportGuid + '" action="view" format="1"/></PROJECT>';

	RqlConnectorObj.SendRql(RqlXml, true, function(data){
		$(ReportContainer).find('.modal-body').html(data);
	});
}

JobReportManager.prototype.DeleteSelectedReports = function(ReportGuidsArray) {
	var ThisClass = this;
	var DeleteJoBReportRql = '';
	var RqlXml;
	var ProcessingContainer = $(this.TemplateProcessing).attr('data-container');
	
	this.UpdateArea(this.TemplateProcessing, {});
	
	$(ProcessingContainer).find('.modal').modal('show');

	$.each(ReportGuidsArray, function(){
		var Guid = this;
		
		DeleteJoBReportRql += '<EXPORTREPORT guid="' + Guid + '" action="delete"/>';
	});
	
	RqlXml = '<PROJECT>' + DeleteJoBReportRql + '</PROJECT>';
	
	RqlConnectorObj.SendRql(RqlXml, false, function(retXML){
		$(ProcessingContainer).find('.modal').modal('hide');
	
		// refresh page
		location.reload(true);
	});
}

JobReportManager.prototype.UpdateArea = function(TemplateId, Data){
	var ContainerId = $(TemplateId).attr('data-container');
	var TemplateAction = $(TemplateId).attr('data-action');
	var Template = Handlebars.compile($(TemplateId).html());
	var TemplateData = Template(Data);

	if((TemplateAction == 'append') || (TemplateAction == 'replace'))
	{
		if (TemplateAction == 'replace') {
			$(ContainerId).empty();
		}

		$(ContainerId).append(TemplateData);
	}

	if(TemplateAction == 'prepend')
	{
		$(ContainerId).prepend(TemplateData);
	}

	if(TemplateAction == 'after')
	{
		$(ContainerId).after(TemplateData);
	}
}