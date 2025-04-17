<?xml version="1.0" encoding="UTF-8"?>
<!--  This EAD stylesheet is reworked from the EAD Cookbook Style 6 and dsc1                 -->
<!--  an original copy can be found here:                                                    -->
<!--  https://github.com/saa-ead-roundtable/ead-stylesheets/tree/master/print-friendly-html  -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:strip-space elements="*"/>
	<xsl:output method="html" encoding="UTF-8" doctype-public="-//W3C//DTD HTML 4.0 Transitional//EN"/>
	<!-- Creates the body of the finding aid.-->
	<xsl:template match="/ead">
		<html lang="en">
			<!-- ****************************************************************** -->
			<!-- Outputs header information for the HTML document 			-->
			<!-- ****************************************************************** -->
			<head>
				<link rel="stylesheet" href="/assets/print.scss"/>
				<link rel="shortcut icon" type="image/x-icon" href="/assets/favicon.ico"/>
				<title>
					<xsl:apply-templates select="eadheader/filedesc/titlestmt/titleproper"/>
				</title>
			</head>


			<body class="ead-print">

				<div class="title-block">
					<xsl:if test="eadheader/filedesc/titlestmt/titleproper">
						<h1 class="finding-aid-title">
							<xsl:apply-templates select="eadheader/filedesc/titlestmt/titleproper"/>
						</h1>
					</xsl:if>

					<xsl:if test="/ead/eadheader/filedesc/titlestmt/subtitle">
						<h2 class="finding-aid-subtitle">
							<xsl:apply-templates select="/ead/eadheader/filedesc/titlestmt/subtitle"/>
						</h2>
					</xsl:if>


					<p class="finding-aid-author">
						<xsl:apply-templates select="eadheader/filedesc/titlestmt/author"/>
					</p>
				</div>

				<!--To change the order of display, adjust the sequence of
				the following apply-template statements which invoke the various
				templates that populate the finding aid. In several cases where
				multiple elements are displayed together in the output, a call-template
				statement is used -->

				<div class="archdesc-overview">
					<xsl:apply-templates select="archdesc/did"/>
				</div>

				<div class="archdesk-main">
					<xsl:apply-templates select="archdesc/bioghist"/>
					<xsl:apply-templates select="archdesc/scopecontent"/>
					<xsl:apply-templates select="archdesc/arrangement"/>
					<xsl:apply-templates select="archdesc/otherfindaid"/>
					<xsl:call-template name="archdesc-restrict"/>
					<xsl:apply-templates select="archdesc/separatedmaterial"/>
					<xsl:apply-templates select="archdesc/relatedmaterial"/>
					<xsl:apply-templates select="archdesc/controlaccess"/>
					<xsl:apply-templates select="archdesc/odd"/>
					<xsl:apply-templates select="archdesc/originalsloc"/>
					<xsl:apply-templates select="archdesc/phystech"/>
					<xsl:call-template name="archdesc-admininfo"/>
					<xsl:apply-templates select="archdesc/fileplan | archdesc/*/fileplan"/>
					<xsl:apply-templates select="archdesc/bibliography"/>
					<xsl:apply-templates select="archdesc/dsc[count(*)>0]"/>
					<xsl:apply-templates select="archdesc/index | archdesc/*/index"/>
				</div>
			</body>
		</html>
	</xsl:template>


	<!-- ************************************************************** -->
	<!-- DID processing:                                                -->
	<!-- This template creates a table for the top-level did, followed  -->
	<!-- by each of the did elements.  To change the order of 	        -->
	<!-- appearance of these elements, change the sequence here.		-->
	<!-- ************************************************************** -->

	<xsl:template match="archdesc/did">
		<div class="archdesc did">
			<table class="overview">
				<xsl:apply-templates select="origination"/>
				<xsl:apply-templates select="unittitle"/>
				<xsl:apply-templates select="unitid"/>
				<xsl:apply-templates select="unitdate[1]"/>
				<xsl:apply-templates select="physdesc"/>
				<xsl:apply-templates select="abstract"/>
				<xsl:apply-templates select="physloc"/>
				<xsl:apply-templates select="langmaterial"/>
				<xsl:apply-templates select="repository"/>
				<xsl:apply-templates select="materialspec"/>
				<xsl:apply-templates select="note"/>
			</table>
		</div>
	</xsl:template>


	<!-- ******************************************************************	-->
	<!-- Formats variety of text properties (bold, italic) from @RENDER     -->
	<!-- Also BLOCKQUOTE handling                                           -->
	<!-- ****************************************************************** -->

	<xsl:template match="p">
		<p>
			<xsl:apply-templates/>
		</p>
	</xsl:template>

	<xsl:template match="lb">
		<br/>
	</xsl:template>

	<!-- add whitespace between any two adjacent text() elements -->
	<!-- except for <head> elements which often get a colon added directly after -->
	<xsl:variable name="space" select="'&#x20;'"/>
	<xsl:template match="//*[name()!='head']/text()">
		<xsl:value-of select="."/>
		<xsl:value-of select="$space"/>
	</xsl:template>

	<xsl:template match="blockquote">
		<blockquote>
			<xsl:apply-templates/>
		</blockquote>
	</xsl:template>

	<xsl:template match="blockquote/p">
		<blockquote>
			<xsl:apply-templates/>
		</blockquote>
	</xsl:template>

	<xsl:template match="emph[@render='bold']">
		<b>
			<xsl:apply-templates/>
		</b>
	</xsl:template>

	<xsl:template match="emph[@render='italic']">
		<i>
			<xsl:apply-templates/>
		</i>
	</xsl:template>

	<xsl:template match="emph[@render='underline']">
		<u>
			<xsl:apply-templates/>
		</u>
	</xsl:template>

	<xsl:template match="emph[@render='sub']">
		<sub>
			<xsl:apply-templates/>
		</sub>
	</xsl:template>

	<xsl:template match="emph[@render='super']">
		<super>
			<xsl:apply-templates/>
		</super>
	</xsl:template>

	<xsl:template match="emph[@render='bolditalic']">
		<b>
			<i>
				<xsl:apply-templates/>
			</i>
		</b>
	</xsl:template>

	<xsl:template match="title">
		<i>
			<xsl:apply-templates/>
		</i>
	</xsl:template>

	<!-- Adds parens around extent elements except for the first entry in archdesc/did -->
	<xsl:template match="extent | physfacet">
		<xsl:choose>
			<xsl:when test="ancestor::did and position() = 1">
				<xsl:apply-templates/>
			</xsl:when>
			<xsl:otherwise>
				(<xsl:apply-templates/>)
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<!-- ****************************************************************** -->
	<!-- LIST                                                               -->
	<!-- Formats a list anywhere except in ARRANGEMENT or REVISIONDESC.     -->
	<!-- Two values for attribute TYPE are implemented: "simple" gives      -->
	<!-- an indented list with no marker, "marked" gives an indented list   -->
	<!-- with each item bulleted, "ordered" gives a numbered list.          -->
	<!-- ****************************************************************** -->


	<xsl:template match="list[@type='ordered']">
		<xsl:if test="./item">
			<ol>
				<xsl:apply-templates/>
			</ol>
		</xsl:if>
	</xsl:template>

	<xsl:template match="list[@type='simple'] | list[@type='deflist']">
		<xsl:if test="./defitem">
			<ol class="no-bullets">
				<xsl:apply-templates/>
			</ol>
		</xsl:if>
	</xsl:template>

	<xsl:template match="list">
		<ul>
			<xsl:apply-templates/>
		</ul>
	</xsl:template>

	<xsl:template match="list/item | defitem">
		<li>
			<xsl:apply-templates/>
		</li>
	</xsl:template>

	<xsl:template match="defitem/label">
		<xsl:if test="not(text()=' ' or text()='' or not(text()))">
			<b>
				<xsl:apply-templates/>:
				<xsl:value-of select="$space"/>
			</b>
		</xsl:if>
	</xsl:template>

	<xsl:template match="bibref">
		<li class="bibliography">
			<xsl:apply-templates/>
		</li>
	</xsl:template>


	<!-- ****************************************************************** -->
	<!-- TABLE                                                              -->
	<!-- Implements a very basic crosswalk of EAD <table> to HTML <table>   -->
	<!-- as of 2022/06/28, IU has only one collection that uses <table>,    -->
	<!-- see InU-Ar-VAA1616                                                 -->
	<!-- ****************************************************************** -->

	<xsl:template match="table">
		<table>
			<xsl:apply-templates/>
		</table>
	</xsl:template>

	<xsl:template match="thead">
		<thead>
			<xsl:apply-templates/>
		</thead>
	</xsl:template>

	<xsl:template match="tbody">
		<tbody>
			<xsl:apply-templates/>
		</tbody>
	</xsl:template>

	<xsl:template match="thead/row | tbody|row">
		<tr>
			<xsl:apply-templates/>
		</tr>
	</xsl:template>

	<xsl:template match="entry">
		<td>
			<xsl:apply-templates/>
		</td>
	</xsl:template>


	<!-- ****************************************************************** -->
	<!-- CHRONLIST                                                          -->
	<!-- Formats a chronology list with items                               -->
	<!-- ****************************************************************** -->

	<xsl:template match="chronlist">
		<table class="chronlist">
			<tbody>
				<xsl:apply-templates/>
			</tbody>
		</table>
	</xsl:template>

	<xsl:template match="chronlist/head">
		<tr>
			<td colspan="2">
				<h4>
					<xsl:apply-templates/>
				</h4>
			</td>
		</tr>
	</xsl:template>

	<xsl:template match="chronlist/listhead">
		<tr>
			<td class="date">
				<b>
					<xsl:apply-templates select="head01"/>
				</b>
			</td>
			<td class="event">
				<b>
					<xsl:apply-templates select="head02"/>
				</b>
			</td>
		</tr>
	</xsl:template>

	<xsl:template match="chronitem">
		<tr>
			<td class="date">
				<xsl:apply-templates select="date"/>
			</td>
			<td class="event">
				<xsl:apply-templates select="event | eventgrp"/>
			</td>
		</tr>
	</xsl:template>

	<xsl:template match="chronitem/eventgrp">
		<xsl:for-each select="*">
			<xsl:apply-templates/>
			<br/>
		</xsl:for-each>
	</xsl:template>


	<!-- ****************************************************************** -->
	<!-- TITLEPROPER and SUBTITLE are output                                -->
	<!-- ****************************************************************** -->

	<!-- suppress <num> nodes from titles -->
	<xsl:template match="eadheader/filedesc/titlestmt/titleproper">
		<xsl:apply-templates select="node()[name() != 'num']"/>
	</xsl:template>

	<!-- suppress <titleproper type='filing'> elements -->
	<xsl:template match="titleproper[@type='filing']"/>

	<xsl:template match="eadheader/filedesc/titlestmt/author">
		<xsl:if test="not(contains(text(), 'Finding'))">
			Finding aid created by
		</xsl:if>
		<xsl:apply-templates/>
	</xsl:template>


	<!-- ****************************************************************** -->
	<!-- COLLECTION INFO:                                                   -->
	<!-- This handles origination, physdesc, abstract, unitid,              -->
	<!-- physloc and materialspec elements of archdesc/did which share a    -->
	<!-- common appearance.  Labels are also generated; to change the label -->
	<!-- generated for these sections, modify the text below.               -->
	<!-- ****************************************************************** -->

	<xsl:template match="archdesc/did/origination
	| archdesc/did/unittitle
	| archdesc/did/unitdate
	| archdesc/did/physdesc
	| archdesc/did/unitid
	| archdesc/did/physloc
	| archdesc/did/abstract
	| archdesc/did/langmaterial
	| archdesc/did/materialspec">

		<!-- ****************************************************************** -->
		<!-- Tests for @LABEL.  If @LABEL is present it is used, otherwise      -->
		<!-- a label is supplied (to alter supplied text, make change below).   -->
		<!-- ****************************************************************** -->

		<tr>
			<td class="did-label">
				<xsl:choose>
					<!-- Use @label if it exists -->
					<xsl:when test="@label">
						<xsl:value-of select="@label"/>
						<xsl:text>:</xsl:text>
					</xsl:when>

					<!--Otherwise, use default label based on the node type  -->
					<xsl:when test="self::unittitle">
						<xsl:text>Title:</xsl:text>
					</xsl:when>
					<xsl:when test="self::repository">
						<xsl:text>Repository:</xsl:text>
					</xsl:when>
					<xsl:when test="self::origination">
						<xsl:text>Creator:</xsl:text>
					</xsl:when>
					<xsl:when test="self::physdesc">
						<xsl:text>Quantity:</xsl:text>
					</xsl:when>
					<xsl:when test="self::physloc">
						<xsl:text>Location:</xsl:text>
					</xsl:when>
					<xsl:when test="self::unitid">
						<xsl:text>Collection No.:</xsl:text>
					</xsl:when>
					<xsl:when test="self::unitdate">
						<xsl:text>Dates:</xsl:text>
					</xsl:when>
					<xsl:when test="self::abstract">
						<xsl:text>Abstract:</xsl:text>
					</xsl:when>
					<xsl:when test="self::langmaterial">
						<xsl:text>Language:</xsl:text>
					</xsl:when>
					<xsl:when test="self::materialspec">
						<xsl:text>Technical:</xsl:text>
					</xsl:when>

					<!-- Include an easily searchable fail-over label in case we missed any node types -->
					<xsl:otherwise>
						<xsl:text>ID Section:</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<td class="did-value">
				<xsl:apply-templates/>
			</td>
		</tr>
	</xsl:template>

	<!-- ****************************************************************** -->
	<!-- REPOSITORY                                                         -->
	<!-- Provides special handling to pull in publisher address from header -->
	<!-- ****************************************************************** -->

	<xsl:template match="archdesc/did/repository">
		<tr>
			<td class="did-label">
				<xsl:choose>
					<!-- Use @label if it exists -->
					<xsl:when test="@label">
						<xsl:value-of select="@label"/>
						<xsl:text>: </xsl:text>
					</xsl:when>
					<!--Otherwise, use default label based on the node type  -->
					<xsl:otherwise>
						<xsl:text>Repository:</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<td class="did-value">
				<xsl:apply-templates select="@* | node()"/>
				<br/>
				<xsl:apply-templates select="/ead/eadheader/filedesc/publicationstmt/address"/>
			</td>
		</tr>
	</xsl:template>

	<xsl:template match="addressline">
		<xsl:apply-templates/>
		<br/>
	</xsl:template>

	<xsl:template match="addressline/extptr" xmlns:xlink="http://www.w3.org/1999/xlink" >
		<xsl:choose>
			<xsl:when test="text()">
				<xsl:apply-templates/>
			</xsl:when>
			<xsl:when test="@title | @xlink:title">
				<xsl:value-of select="@title | @xlink:title"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="@href | @xlink:href"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<!-- ****************************************************************** -->
	<!-- UNITDATE                                                           -->
	<!-- Concatenate all <unitdate> sibling nodes & display @type           -->
	<!-- ****************************************************************** -->

	<xsl:template match="unitdate/child::text()">
		<xsl:for-each select="parent::node()/../unitdate">
			<!-- display type if there are additional unitdate nodes -->
			<xsl:if test="position() != 1 and @type!='inclusive'">
				<xsl:value-of select="@type"/>
				<xsl:value-of select="$space"/>
			</xsl:if>

			<!-- display the unitdate -->
			<xsl:value-of select="."/>

			<!-- separate multiple entries with a comma -->
			<xsl:if test="position() != last()">
				<xsl:text>,</xsl:text>
				<xsl:value-of select="$space"/>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>


	<!-- ****************************************************************** -->
	<!-- ARCHDESC Processing                                                -->
	<!-- Formats the top-level bioghist, scopecontent, phystech, odd, and   -->
	<!-- arrangement elements and creates a link back to the top of the     -->
	<!-- page after the display of the element.  Each HEAD element is also  -->
	<!-- given a generated ID so it can be linked to from the TOC.          -->
	<!-- ****************************************************************** -->

	<xsl:template match="archdesc/bioghist |
		archdesc/scopecontent |
		archdesc/phystech |
		archdesc/odd   |
		archdesc/arrangement |
		archdesc/separatedmaterial |
		archdesc/relatedmaterial |
		archdesc/controlaccess |
		archdesc/otherfindaid |
		archdesc/originalsloc |
		archdesc/fileplan |
		archdesc/dsc |
		archdesc/index">
		<div>
			<xsl:attribute name="class">archdesc-section
				<xsl:value-of select="name()"/>
			</xsl:attribute>
			<xsl:apply-templates/>
		</div>
	</xsl:template>

	<xsl:template match="archdesc/bibliography">
		<div>
			<xsl:attribute name="class">archdesc-section
				<xsl:value-of select="name()"/>
			</xsl:attribute>
			<xsl:apply-templates select="head"/>
			<div class="bibliography">
				<xsl:apply-templates select="*[name()!='head']"/>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="archdesc/*/head">
		<h3>
			<xsl:apply-templates/>
		</h3>
	</xsl:template>

	<!-- ****************************************************************** -->
	<!-- Controlled Access headings                                         -->
	<!-- Formats controlled access headings.  Does NOT handle recursive 	-->
	<!-- controlaccess elements. Does NOT require HEAD elements (makes for	-->
	<!-- easier tagging), instead captions are generated.  Subelements      -->
	<!-- (genreform, etc) do not need to be alphabetized or sorted by type, -->
	<!-- the style sheet handles this.                                      -->
	<!-- ****************************************************************** -->

	<!-- top-level entry point -->
	<xsl:template match="wip-archdesc/controlaccess">
		<div class="archdesc-section controlaccess">
			<h3>Indexed Terms</h3>
			<xsl:apply-templates select="*" mode="top-level"/>
		</div>
	</xsl:template>

	<!-- compoent-level entry point and formatting -->
	<xsl:template match="dsc//controlaccess">
		<p class="controlaccess">
			<span class="label">Indexed Terms:</span>
			<ul class="subject-headings">
				<xsl:apply-templates select="subject[1] | title[1]  |
				persname[1]  | famname[1]  | corpname[1]  |
				geogname[1]  | genreform[1]  | occupation[1]  |
				function[1]" mode="component"/>
			</ul>
		</p>
	</xsl:template>

	<!-- Group controlaccess elements by type -->
	<xsl:template match="controlaccess/subject[1]" mode="component">
		<li class="subj-label">
			<span class="label">Subjects:</span>
			<ul class="subject-value">
				<xsl:apply-templates select="../child::subject"/>
			</ul>
		</li>
	</xsl:template>

	<xsl:template match="controlaccess/title[1]" mode="component">
		<li class="subj-label">
			<span class="label">Associated Titles:</span>
			<ul class="subject-value">
				<xsl:apply-templates select="../child::title"/>
			</ul>
		</li>
	</xsl:template>

	<xsl:template match="controlaccess/persname[1]" mode="component">
		<li class="subj-label">
			<span class="label">People:</span>
			<ul class="subject-value">
				<xsl:apply-templates select="../child::persname"/>
			</ul>
		</li>
	</xsl:template>

	<xsl:template match="controlaccess/famname[1]" mode="component">
		<li class="subj-label">
			<span class="label">Family Names:</span>
			<ul class="subject-value">
				<xsl:apply-templates select="../child::famname"/>
			</ul>
		</li>
	</xsl:template>

	<xsl:template match="controlaccess/corpname[1]" mode="component">
		<li class="subj-label">
			<span class="label">Corporate Bodies:</span>
			<ul class="subject-value">
				<xsl:apply-templates select="../child::corpname"/>
			</ul>
		</li>
	</xsl:template>

	<xsl:template match="controlaccess/geogname[1]" mode="component">
		<li class="subj-label">
			<span class="label">Places:</span>
			<ul class="subject-value">
				<xsl:apply-templates select="../child::geogname"/>
			</ul>
		</li>
	</xsl:template>

	<xsl:template match="controlaccess/genreform[1]" mode="component">
		<li class="subj-label">
			<span class="label">Genre and Forms:</span>
			<ul class="subject-value">
				<xsl:apply-templates select="../child::genreform"/>
			</ul>
		</li>
	</xsl:template>

	<xsl:template match="controlaccess/occupation[1]" mode="component">
		<li class="subj-label">
			<span class="label">Occupations:</span>
			<ul class="subject-value">
				<xsl:apply-templates select="../child::occupation"/>
			</ul>
		</li>
	</xsl:template>

	<xsl:template match="controlaccess/function[1]" mode="component">
		<li class="subj-label">
			<span class="label">Functions:</span>
			<ul class="subject-value">
				<xsl:apply-templates select="../child::function"/>
			</ul>
		</li>
	</xsl:template>

	<xsl:template match="controlaccess/*">
		<li>
			<xsl:apply-templates/>
		</li>
	</xsl:template>

	<xsl:template match="archdesc/controlaccess">
		<div class="archdesc-section controlaccess">
		<h3>Indexed Terms</h3>
		<ul class="subject-headings">
			<xsl:for-each select=".">
				<xsl:if test="persname | famname">
					<li class="subj-label">
						<h5>Persons</h5>
						<ul class="subj-values">
							<xsl:for-each select="famname | persname">
								<xsl:sort select="." data-type="text" order="ascending"/>
								<li>
									<xsl:apply-templates/>
								</li>
							</xsl:for-each>
						</ul>
					</li>
				</xsl:if>
				<xsl:if test="corpname">
					<li class="subj-label">
						<h5>Corporate Bodies</h5>
						<ul class="subj-values">
							<xsl:for-each select="corpname">
								<xsl:sort select="." data-type="text" order="ascending"/>
								<li>
									<xsl:apply-templates/>
								</li>
							</xsl:for-each>
						</ul>
					</li>
				</xsl:if>
				<xsl:if test="title">
					<li class="subj-label">
						<h5>Associated Titles</h5>
						<ul class="subj-values">
							<xsl:for-each select="title">
								<xsl:sort select="." data-type="text" order="ascending"/>
								<li>
									<xsl:apply-templates/>
								</li>
							</xsl:for-each>
						</ul>
					</li>
				</xsl:if>
				<xsl:if test="subject">
					<li class="subj-label">
						<h5>Subjects</h5>
						<ul class="subj-values">
							<xsl:for-each select="subject">
								<xsl:sort select="." data-type="text" order="ascending"/>
								<li>
									<xsl:apply-templates/>
								</li>
							</xsl:for-each>
						</ul>
					</li>
				</xsl:if>
				<xsl:if test="geogname">
					<li class="subj-label">
						<h5>Places</h5>
						<ul class="subj-values">
							<xsl:for-each select="geogname">
								<xsl:sort select="." data-type="text" order="ascending"/>
								<li>
									<xsl:apply-templates/>
								</li>
							</xsl:for-each>
						</ul>
					</li>
				</xsl:if>
				<xsl:if test="genreform">
					<li class="subj-label">
						<h5>Genres and Forms</h5>
						<ul class="subj-values">
							<xsl:for-each select="genreform">
								<xsl:sort select="." data-type="text" order="ascending"/>
								<li>
									<xsl:apply-templates/>
								</li>
							</xsl:for-each>
						</ul>
					</li>
				</xsl:if>
				<xsl:if test="occupation | function">
					<li class="subj-label">
						<h5>Occupations</h5>
						<ul class="subj-values">
							<xsl:for-each select="occupation | function">
								<xsl:sort select="." data-type="text" order="ascending"/>
								<li>
									<xsl:apply-templates/>
								</li>
							</xsl:for-each>
						</ul>
					</li>
				</xsl:if>
			</xsl:for-each>
		</ul>
		</div>
	</xsl:template>


	<!-- ****************************************************************** -->
	<!-- Access and Use Restriction processing                              -->
	<!-- Inclused processing of any NOTE child elements.                    -->
	<!-- ****************************************************************** -->

	<xsl:template name="archdesc-restrict">
		<xsl:if test="string(archdesc/userestrict/*)
		or string(archdesc/accessrestrict/*)">
			<div class="archdesc-section restrict">
				<h3>
					<xsl:text>Restrictions</xsl:text>
				</h3>

				<div class="accessrestrict">
					<xsl:apply-templates select="archdesc/accessrestrict"/>
				</div>

				<div class="userrestrict">
					<xsl:apply-templates select="archdesc/userestrict"/>
				</div>
			</div>
		</xsl:if>
	</xsl:template>

	<xsl:template match="archdesc/accessrestrict/head |
			     archdesc/userestrict/head">
		<h4><xsl:apply-templates/>:
		</h4>
	</xsl:template>


	<!-- ****************************************************************** -->
	<!-- Other Admin Info processing                                        -->
	<!-- Inclused processing of any other administrative information        -->
	<!-- elements and consolidates them into one block under a common       -->
	<!-- heading, "Administrative Information."  If child elements contain  -->
	<!-- a HEAD element it is retained and used as the section title.       -->
	<!-- ****************************************************************** -->

	<xsl:template name="archdesc-admininfo">
		<xsl:if test="string(archdesc/admininfo/custodhist/*)
		or string(archdesc/altformavail/*)
		or string(archdesc/prefercite/*)
		or string(archdesc/acqinfo/*)
		or string(archdesc/processinfo/*)
		or string(archdesc/appraisal/*)
		or string(archdesc/accruals/*)
		or string(archdesc/*/custodhist/*)
		or string(archdesc/*/altformavail/*)
		or string(archdesc/*/prefercite/*)
		or string(archdesc/*/acqinfo/*)
		or string(archdesc/*/processinfo/*)
		or string(archdesc/*/appraisal/*)
		or string(archdesc/*/accruals/*)">
			<div class="archdesc-section admininfo">
				<h3>
					<xsl:text>Administrative Information</xsl:text>
				</h3>

				<xsl:apply-templates select="archdesc/custodhist
				| archdesc/*/custodhist"/>
				<xsl:apply-templates select="archdesc/altformavail
				| archdesc/*/altformavail"/>
				<xsl:apply-templates select="archdesc/prefercite
				| archdesc/*/prefercite"/>
				<xsl:apply-templates select="archdesc/acqinfo
				| archdesc/*/acqinfo"/>
				<xsl:apply-templates select="archdesc/processinfo
				| archdesc/*/processinfo"/>
				<xsl:apply-templates select="archdesc/admininfo/appraisal
				| archdesc/*/appraisal"/>
				<xsl:apply-templates select="archdesc/admininfo/accruals
				| archdesc/*/accruals"/>
			</div>
		</xsl:if>
	</xsl:template>


	<!-- ****************************************************************** -->
	<!-- INVENTORY LIST PROCESSING	<dsc> & <cxx>                           -->
	<!-- Now we get into the actual box/folder listings			            -->
	<!-- ****************************************************************** -->

	<xsl:template match="archdesc/dsc">
		<div class="archdesc-section dsc">
			<h3>
				<xsl:choose>
					<xsl:when test="dsc/head">
						<xsl:value-of select="head"/>
					</xsl:when>
					<xsl:otherwise>
						Collection Inventory
					</xsl:otherwise>
				</xsl:choose>
			</h3>
			<xsl:apply-templates/>
		</div>
	</xsl:template>

	<xsl:template match="c | c01 | c02 | c03 | c04 | c05 | c06 | c07 | c08 | c09 | c10 | c11 | c12">
		<div>
			<xsl:attribute name="class">component <xsl:value-of select="name()"/>
			</xsl:attribute>

			<div class="box-folder">
				<xsl:apply-templates select="did" mode="container"/>
			</div>

			<div class="component-info">
				<!-- Change the order below to change printed order -->
				<xsl:apply-templates select="did"/>
				<xsl:apply-templates select="scopecontent"/>
				<xsl:apply-templates select="bioghist"/>
				<xsl:apply-templates select="processinfo"/>
				<xsl:apply-templates select="phystech"/>
				<xsl:apply-templates select="acqinfo"/>
				<xsl:apply-templates select="custodhist"/>
				<xsl:apply-templates select="originalsloc"/>
				<xsl:apply-templates select="arrangement"/>
				<xsl:apply-templates select="relatedmaterial"/>
				<xsl:apply-templates select="separatedmaterial"/>
				<xsl:apply-templates select="prefercite"/>
				<xsl:apply-templates select="controlaccess"/>
				<xsl:apply-templates select="otherfindaid"/>
				<xsl:apply-templates select="odd"/>
				<xsl:apply-templates select="altformavail"/>
				<xsl:apply-templates select="accessrestrict"/>
				<xsl:apply-templates select="userestrict"/>
			</div>

		</div> <!-- container -->
		<xsl:apply-templates select="c01 | c02 | c03 | c04 | c05 | c06 | c07 | c08 | c09 | c10 | c11 | c12"/>
	</xsl:template>

	<xsl:template match="did" mode="container">
		<xsl:for-each select="container">
			<xsl:if test="position() > 1">
				<br/>
			</xsl:if>
			<xsl:apply-templates select="@type"/>
			<xsl:text> </xsl:text>
			<xsl:apply-templates select="text() | *"/>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="dsc//accessrestrict | dsc//acqinfo | dsc//altformavail | dsc//arrangement | dsc//bioghist |
		dsc/c01/custodhist | dsc//odd | dsc//originalsloc | dsc//otherfindaid | dsc//prefercite | dsc//processinfo |
		dsc//phystech | dsc//relatedmaterial | dsc//scopecontent | dsc//separatedmaterial | dsc//userestrict">
		<p>
			<!-- embed the <head> text in the first paragraph and process the remaining contents fromm p[1] -->
			<span class="label">
				<xsl:apply-templates select="head"/>
				<xsl:text>: </xsl:text>
			</span>
			<xsl:apply-templates select="p[1]/text() | p[1]/*"/>
		</p>
		<!-- Process other child nodes - exclude head and p[1] because they've been handled above -->
		<xsl:apply-templates select="*[(not(self::head) and not(self::p))] | child::p[position()>1] "/>
	</xsl:template>

	<xsl:template match="dsc//did">
		<xsl:apply-templates select="../@level"/>
		<div>
			<xsl:attribute name="class">unittitle <xsl:value-of select="../@level"/>
			</xsl:attribute>
			<xsl:apply-templates select="unittitle"/>
			<xsl:apply-templates select="unitdate[1]"/>
		</div>
		<xsl:apply-templates select="unitid[@type or (count(..//unitid[@type])=0 and position()=1)]"/>
		<!-- Julie H 2024-10-10 - adding component level origination -->
		<xsl:apply-templates select="origination"/>
		<xsl:apply-templates select="physdesc"/>
		<xsl:apply-templates select="langmaterial"/>
	</xsl:template>

	<xsl:template match="dsc//unittitle">
		<xsl:apply-templates/>
		<xsl:if test="../unitdate">
			<xsl:text>,</xsl:text>
			<xsl:value-of select="$space"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="dsc//did/unitid">
		<p>
			<span class="label">
				<xsl:value-of select="@type"/>
				<xsl:text> No(s): </xsl:text>
			</span>
			<xsl:apply-templates select="node()"/>
		</p>
	</xsl:template>

	<!-- Julie H 2024-10-10 - selecting @label and content within origination (often within <persname>); 2024-10-28 - adding colon and space after label -->
	<xsl:template match="dsc//did/origination">
		<p>
			<span class="label">
				<xsl:value-of select="@label"/><xsl:text>: </xsl:text>
			</span>
			<xsl:apply-templates/>
		</p>
	</xsl:template>

	<xsl:template match="dsc//did/physdesc[not(child::dimensions or child::extent)]">
		<p>
			<span class="label">
				<xsl:value-of select="@type"/>
				<xsl:text>Physical Description: </xsl:text>
			</span>
			<xsl:apply-templates/>
		</p>
	</xsl:template>

	<xsl:template match="did/physdesc/dimensions">
		<p>
			<span class="label">
				<xsl:value-of select="@type"/>
				<xsl:text>Dimensions: </xsl:text>
			</span>
			<xsl:apply-templates select="node()"/>
		</p>
	</xsl:template>

	<xsl:template match="did/physdesc/extent">
		<p>
			<span class="label">
				<xsl:value-of select="@type"/>
				<xsl:text>Quantity: </xsl:text>
			</span>
			<xsl:apply-templates select="node()"/>
		</p>
	</xsl:template>

	<xsl:template match="dsc//did/langmaterial">
		<p>
			<span class="label">
				<xsl:value-of select="@type"/>
				<xsl:text>Language: </xsl:text>
			</span>
			<xsl:apply-templates select="node()"/>
		</p>
	</xsl:template>

	<xsl:template match="attribute::level">
		<xsl:choose>
			<xsl:when test="../@level='series'">
				<h4 class="label">
					Series:
				</h4>
			</xsl:when>
			<xsl:when test="../@level='subseries'">
				<h4 class="label">
					Subseries:
				</h4>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
