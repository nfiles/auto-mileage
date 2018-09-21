import { Component } from '@angular/core';
import { FormGroup, FormControl } from '@angular/forms';

@Component({
  selector: 'app-entry',
  templateUrl: './entry.component.html',
  styleUrls: ['./entry.component.css'],
})
export class EntryComponent {
  form = new FormGroup({
    vehicleId: new FormControl(null),
    date: new FormControl(''),
    miles: new FormControl(null),
    gallons: new FormControl(null),
    comments: new FormControl(''),
  });

  constructor() {}
}
