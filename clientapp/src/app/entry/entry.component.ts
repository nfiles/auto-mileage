import { Component, OnInit, ViewChild } from '@angular/core';
import { FormGroup, FormControl, NgForm } from '@angular/forms';

@Component({
  selector: 'app-entry',
  templateUrl: './entry.component.html',
  styleUrls: ['./entry.component.css'],
})
export class EntryComponent implements OnInit {
  public form: FormGroup;

  constructor() {
    this.form = new FormGroup({
      date: new FormControl(''),
      miles: new FormControl(null),
      gallons: new FormControl(null),
    });
  }

  ngOnInit() {
    console.log(this.form);
  }
}
