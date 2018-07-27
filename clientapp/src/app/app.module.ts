import { BrowserModule } from '@angular/platform-browser';
import { RouterModule } from '@angular/router';
import { NgModule } from '@angular/core';
import { BsDatepickerModule } from 'ngx-bootstrap/datepicker';

import { AppComponent } from './app.component';
import { EntryComponent } from './entry/entry.component';
import { SummaryComponent } from './summary/summary.component';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';

@NgModule({
  declarations: [AppComponent, EntryComponent, SummaryComponent],
  imports: [
    BrowserModule,
    RouterModule.forRoot([
      { path: 'entry', component: EntryComponent },
      { path: 'summary', component: SummaryComponent },
      { path: '', redirectTo: 'entry', pathMatch: 'full' },
      { path: '**', redirectTo: 'entry' },
    ]),
    BsDatepickerModule.forRoot(),
    ReactiveFormsModule,
  ],
  providers: [],
  bootstrap: [AppComponent],
})
export class AppModule {}
