// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Apps;

using System.Environment.Configuration;

/// <summary>
/// Displays settings for the selected extension, and allows users to edit them.
/// </summary>
page 2511 "Extension Settings"
{
    ApplicationArea = All;
    Extensible = false;
    DataCaptionExpression = AppNameValue;
    PageType = Card;
    SourceTable = "NAV App Setting";
    ContextSensitiveHelpPage = 'ui-extensions';
    Permissions = tabledata "Nav App Setting" = rm,
                  tabledata "Published Application" = r;

    layout
    {
        area(Content)
        {
            group(Group)
            {
                Caption = 'General';

                field(AppId; AppIdValue)
                {
                    Caption = 'App ID';
                    Editable = false;
                    ToolTip = 'Specifies the App ID of the extension.';
                }
                field(AppName; AppNameValue)
                {
                    Caption = 'Name';
                    Editable = false;
                    ToolTip = 'Specifies the name of the extension.';
                }
                field(AppVersion; AppVersionDisplay)
                {
                    Caption = 'Version';
                    Editable = false;
                    ToolTip = 'Specifies the version of the extension.';
                }
                field(AppPublisher; AppPublisherValue)
                {
                    Caption = 'Publisher';
                    Editable = false;
                    ToolTip = 'Specifies the publisher of the extension.';
                }
                field(AppIsInstalled; AppIsInstalled)
                {
                    Caption = 'Is Installed';
                    Editable = false;
                    ToolTip = 'Specifies whether the extension is installed.';
                }
                field(AllowHttpClientRequests; Rec."Allow HttpClient Requests")
                {
                    Caption = 'Allow HttpClient Requests';
                    Editable = CanManageExtensions;
                    ToolTip = 'Specifies whether the runtime should allow this extension to make HTTP requests through the HttpClient data type when running in a non-production environment.';
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        PublishedApplication: Record "Published Application";
    begin
        PublishedApplication.SetRange(ID, Rec."App ID");
        PublishedApplication.SetRange("Tenant Visible", true);

        if PublishedApplication.FindFirst() then begin
            AppNameValue := PublishedApplication.Name;
            AppPublisherValue := PublishedApplication.Publisher;
            AppIdValue := LowerCase(DelChr(Format(PublishedApplication.ID), '=', '{}'));
            AppVersionDisplay := ExtensionInstallationImpl.GetVersionDisplayString(PublishedApplication);
            AppIsInstalled := ExtensionInstallationImpl.IsInstalledByPackageId(PublishedApplication."Package ID");
        end
    end;

    trigger OnOpenPage()
    begin
        if Rec.GetFilter("App ID") = '' then
            exit;

        Rec."App ID" := Rec.GetRangeMin("App ID");
        if not Rec.FindFirst() then begin
            Rec.Init();
            Rec.Insert();
        end;

        CanManageExtensions := ExtensionInstallationImpl.CanManageExtensions();
    end;

    var
        ExtensionInstallationImpl: Codeunit "Extension Installation Impl";
        AppNameValue: Text;
        AppPublisherValue: Text;
        AppIdValue: Text;
        AppVersionDisplay: Text;
        AppIsInstalled: Boolean;
        CanManageExtensions: Boolean;
}


