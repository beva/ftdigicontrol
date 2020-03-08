program ftdigicontrol;
{< @abstract(Main project (lpr) file.)

   @bold(Compile options)

   This application may be compiled in several versions with extra options for special
   use.@br
   Please check Project -> Project Options -> Compiler Options -> Other -> Custom options,
   to set the following compile directives:

   @definitionList(
     @itemSpacing(Compact)
     @itemLabel(@italic(Debug))
     @item(A debug panel is included and some debug information is generated and printed there.)
     @itemLabel(@italic(Verbose))
     @item(Much more debug information is printed @(Not yet implemented!@).)
     @itemLabel(@italic(Simulator))
     @item(Include code for simulation @(Not yet implemented!@).)
   )

}

{$mode objfpc}{$H+}
{$DEFINE UseCThreads}
{$DEFINE SimulatorMode}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads, cmem,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, MainUnit, ProgressHandling, remote_simlator_form
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
