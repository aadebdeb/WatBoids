(module
  (import "env" "memory" (memory 1))
  (global $width (import "env" "width") f64)
  (global $height (import "env" "height") f64)
  (global $num (import "env" "num") i32)
  (global $radius (import "env" "radius") f64)
  (global $max_speed (import "env" "maxSpeed") f64)
  (global $max_force (import "env" "maxForce") f64)
  (global $separation_distance (import "env" "separationDistance") f64)
  (global $align_distance (import "env" "alignDistance") f64)
  (global $cohesion_distance (import "env" "cohesionDistance") f64)
  (global $separation_intensity (import "env" "separationIntensity") f64)
  (global $align_intensity (import "env" "alignIntensity") f64)
  (global $cohesion_intensity (import "env" "cohesionIntensity") f64)
  (global $address_tmp_vector_x (mut i32) (i32.const 0))
  (global $address_tmp_vector_y (mut i32) (i32.const 0))

  (func $load_tmp_vector_x
    (result f64)
    (f64.load (global.get $address_tmp_vector_x))
  )
  (func $store_tmp_vector_x
    (param $value f64)
    (f64.store (global.get $address_tmp_vector_x) (local.get $value))
  )
  (func $load_tmp_vector_y
    (result f64)
    (f64.load (global.get $address_tmp_vector_y))
  )
  (func $store_tmp_vector_y
    (param $value f64)
    (f64.store (global.get $address_tmp_vector_y) (local.get $value))
  )

  (func $sq_length
    (param $x f64)
    (param $y f64)
    (result f64)

    (f64.add
      (f64.mul (local.get $x) (local.get $x))
      (f64.mul (local.get $y) (local.get $y))
    )
  )

  (func $length
    (param $x f64)
    (param $y f64)
    (result f64)

    (f64.sqrt (call $sq_length (local.get $x) (local.get $y)))
  )

  (func $distance
    (param $x0 f64)
    (param $y0 f64)
    (param $x1 f64)
    (param $y1 f64)
    (result f64)

    (call $length
      (f64.sub (local.get $x0) (local.get $x1))
      (f64.sub (local.get $y0) (local.get $y1))
    )
  )

  (func $normalize
    (param $x f64)
    (param $y f64)

    (local $l f64)

    (local.set $l (call $length (local.get $x) (local.get $y)))
    (call $store_tmp_vector_x
      (f64.div (local.get $x) (local.get $l))
    )
    (call $store_tmp_vector_y
      (f64.div (local.get $y) (local.get $l))
    )
  )

  (func $limit
    (param $x f64)
    (param $y f64)
    (param $max f64)

    (local $l f64)

    (local.set $l (call $length (local.get $x) (local.get $y)))
    (if
      (f64.gt (local.get $l) (local.get $max))
      (then
        (local.set $l (f64.div (local.get $max) (local.get $l)))
        (call $store_tmp_vector_x
          (f64.mul (local.get $x) (local.get $l))
        )
        (call $store_tmp_vector_y
          (f64.mul (local.get $y) (local.get $l))
        )
      )
      (else
        (call $store_tmp_vector_x (local.get $x))
        (call $store_tmp_vector_y (local.get $y))
      )
    )
  )

  (func $address_pos_x
    (param $index i32)
    (result i32)
    (i32.mul (local.get $index) (i32.const 48))
  )

  (func $address_pos_y
    (param $index i32)
    (result i32)
    (i32.add
      (i32.mul (local.get $index) (i32.const 48))
      (i32.const 8)
    )
  )

  (func $address_vel_x
    (param $index i32)
    (result i32)
    (i32.add
      (i32.mul (local.get $index) (i32.const 48))
      (i32.const 16)
    )
  )

  (func $address_vel_y
    (param $index i32)
    (result i32)
    (i32.add
      (i32.mul (local.get $index) (i32.const 48))
      (i32.const 24)
    )
  )

  (func $address_acc_x
    (param $index i32)
    (result i32)
    (i32.add
      (i32.mul (local.get $index) (i32.const 48))
      (i32.const 32)
    )
  )


  (func $address_acc_y
    (param $index i32)
    (result i32)
    (i32.add
      (i32.mul (local.get $index) (i32.const 48))
      (i32.const 40)
    )
  )

  (func $load_pos_x
    (param $index i32)
    (result f64)
    (f64.load (call $address_pos_x (local.get $index)))
  )

  (func $load_pos_y
    (param $index i32)
    (result f64)
    (f64.load (call $address_pos_y (local.get $index)))
  )

  (func $load_vel_x
    (param $index i32)
    (result f64)
    (f64.load (call $address_vel_x (local.get $index)))
  )

  (func $load_vel_y
    (param $index i32)
    (result f64)
    (f64.load (call $address_vel_y (local.get $index)))
  )

  (func $load_acc_x
    (param $index i32)
    (result f64)
    (f64.load (call $address_acc_x (local.get $index)))
  )

  (func $load_acc_y
    (param $index i32)
    (result f64)
    (f64.load (call $address_acc_y (local.get $index)))
  )

  (func $store_pos_x
    (param $index i32)
    (param $value f64)
    (f64.store (call $address_pos_x (local.get $index)) (local.get $value))
  )

  (func $store_pos_y
    (param $index i32)
    (param $value f64)
    (f64.store (call $address_pos_y (local.get $index)) (local.get $value))
  )

  (func $store_vel_x
    (param $index i32)
    (param $value f64)
    (f64.store (call $address_vel_x (local.get $index)) (local.get $value))
  )

  (func $store_vel_y
    (param $index i32)
    (param $value f64)
    (f64.store (call $address_vel_y (local.get $index)) (local.get $value))
  )

  (func $store_acc_x
    (param $index i32)
    (param $value f64)
    (f64.store (call $address_acc_x (local.get $index)) (local.get $value))
  )

  (func $store_acc_y
    (param $index i32)
    (param $value f64)
    (f64.store (call $address_acc_y (local.get $index)) (local.get $value))
  )

  (func $separate
    (param $index i32)

    (local $pos_x f64)
    (local $pos_y f64)
    (local $other_pos_x f64)
    (local $other_pos_y f64)
    (local $steer_x f64)
    (local $steer_y f64)
    (local $count i32)
    (local $d f64)
    (local $i i32)

    (local.set $pos_x (call $load_pos_x (local.get $index)))
    (local.set $pos_y (call $load_pos_y (local.get $index)))
    (local.set $steer_x (f64.const 0))
    (local.set $steer_y (f64.const 0))
    (local.set $count (i32.const 0))

    (local.set $i (i32.const 0)) ;; $i = 0
    (loop $continue
      (local.set $other_pos_x (call $load_pos_x (local.get $i)))
      (local.set $other_pos_y (call $load_pos_y (local.get $i)))
      (local.set $d
        (call $distance (local.get $pos_x) (local.get $pos_y) (local.get $other_pos_x) (local.get $other_pos_y))
      )
      (if
        (i32.and
          (f64.gt (local.get $d) (f64.const 0))
          (f64.lt (local.get $d) (global.get $separation_distance))
        )
        (then
          (call $normalize ;; $normalize($pos_x - $other_pos_x, $pos_y - $other_pos_y)
            (f64.sub (local.get $pos_x) (local.get $other_pos_x))
            (f64.sub (local.get $pos_y) (local.get $other_pos_y))
          )
          (local.set $steer_x
            (f64.add
              (local.get $steer_x)
              (f64.div (call $load_tmp_vector_x) (local.get $d))
            )
          )
          (local.set $steer_y
            (f64.add
              (local.get $steer_y)
              (f64.div (call $load_tmp_vector_y) (local.get $d))
            )
          )

          (local.set $count (i32.add (local.get $count) (i32.const 1))) ;; $count += 1
        )
      )
      (local.set $i (i32.add (local.get $i) (i32.const 1))) ;; $i += 1
      (br_if $continue (i32.lt_u (local.get $i) (global.get $num))) ;; continue if: $i < $num
    )

    (if
      (i32.and ;; $count > 0 && $sq_length($steer_x, $steer_y) > 0
        (i32.gt_u (local.get $count) (i32.const 0))
        (f64.gt (call $sq_length (local.get $steer_x) (local.get $steer_y)) (f64.const 0))
      )
      (then
        (call $normalize (local.get $steer_x) (local.get $steer_y))
        (call $limit
          (f64.sub
            (f64.mul
              (call $load_tmp_vector_x)
              (global.get $max_speed)
            )
            (call $load_vel_x (local.get $index))
          )
          (f64.sub
            (f64.mul
              (call $load_tmp_vector_y)
              (global.get $max_speed)
            )
            (call $load_vel_y (local.get $index))
          )
          (global.get $max_force)
        )
        (local.set $steer_x (call $load_tmp_vector_x))
        (local.set $steer_y (call $load_tmp_vector_y))
      )
    )

    (call $store_tmp_vector_x (local.get $steer_x))
    (call $store_tmp_vector_y (local.get $steer_y))
  )

  (func $align
    (param $index i32)

    (local $pos_x f64)
    (local $pos_y f64)
    (local $sum_vel_x f64)
    (local $sum_vel_y f64)
    (local $count i32)
    (local $d f64)
    (local $i i32)

    (local.set $pos_x (call $load_pos_x (local.get $index)))
    (local.set $pos_y (call $load_pos_y (local.get $index)))
    (local.set $sum_vel_x (f64.const 0))
    (local.set $sum_vel_y (f64.const 0))
    (local.set $count (i32.const 0)) ;; $count = 0

    (local.set $i (i32.const 0)) ;; $i = 0
    (loop $continue
      (local.set $d
        (call $distance
          (local.get $pos_x) (local.get $pos_y)
          (call $load_pos_x (local.get $i)) (call $load_pos_y (local.get $i))
        )
      )
      (if
        (i32.and ;; $d > 0 && $d < $align_distance
          (f64.gt (local.get $d) (f64.const 0))
          (f64.lt (local.get $d) (global.get $align_distance))
        )
        (then
          (local.set $sum_vel_x (f64.add (local.get $sum_vel_x) (call $load_vel_x (local.get $i)))) ;; $sum_vel_x += $other_vel_x
          (local.set $sum_vel_y (f64.add (local.get $sum_vel_y) (call $load_vel_y (local.get $i)))) ;; #sum_vel_y += $other_vel_y
          (local.set $count (i32.add (local.get $count) (i32.const 1))) ;; $count += 1
        )
      )

      (local.set $i (i32.add (local.get $i) (i32.const 1))) ;; $i += 1
      (br_if $continue (i32.lt_u (local.get $i) (global.get $num))) ;; continue if: $i < $num
    )

    (if
      (i32.gt_u (local.get $count) (i32.const 0)) ;; $count > 0
      (then
        (call $normalize (local.get $sum_vel_x) (local.get $sum_vel_y))
        (call $limit
          (f64.sub
            (f64.mul
              (call $load_tmp_vector_x)
              (global.get $max_speed)
            )
            (call $load_vel_x (local.get $index))
          )
          (f64.sub
            (f64.mul
              (call $load_tmp_vector_y)
              (global.get $max_speed)
            )
            (call $load_vel_y (local.get $index))
          )
          (global.get $max_force)
        )
        (call $store_tmp_vector_x (call $load_tmp_vector_x))
        (call $store_tmp_vector_y (call $load_tmp_vector_y))
      )
      (else
        (call $store_tmp_vector_x (f64.const 0))
        (call $store_tmp_vector_y (f64.const 0))
      )
    )
  )

  (func $cohesion
    (param $index i32)

    (local $pos_x f64)
    (local $pos_y f64)
    (local $other_pos_x f64)
    (local $other_pos_y f64)
    (local $sum_pos_x f64)
    (local $sum_pos_y f64)
    (local $count i32)
    (local $d f64)
    (local $i i32)

    (local.set $pos_x (call $load_pos_x (local.get $index)))
    (local.set $pos_y (call $load_pos_y (local.get $index)))
    (local.set $sum_pos_x (f64.const 0)) ;; $sum_pos_x = 0
    (local.set $sum_pos_y (f64.const 0)) ;; $sum_pos_y = 0
    (local.set $count (i32.const 0)) ;; $count = 0

    (local.set $i (i32.const 0)) ;; $i = 0
    (loop $continue
      (local.set $other_pos_x (call $load_pos_x (local.get $i)))
      (local.set $other_pos_y (call $load_pos_y (local.get $i)))
      (local.set $d
        (call $distance (local.get $pos_x) (local.get $pos_y) (local.get $other_pos_x) (local.get $other_pos_y))
      )
      (if
        (i32.and ;; $d > 0 && $d < $cohesion_distance
          (f64.gt (local.get $d) (f64.const 0))
          (f64.lt (local.get $d) (global.get $cohesion_distance))
        )
        (then
          (local.set $sum_pos_x (f64.add (local.get $sum_pos_x) (local.get $other_pos_x))) ;; $sum_pos_x += $other_pos_x
          (local.set $sum_pos_y (f64.add (local.get $sum_pos_y) (local.get $other_pos_y))) ;; #sum_pos_y += $other_pos_y
          (local.set $count (i32.add (local.get $count) (i32.const 1))) ;; $count += 1
        )
      )

      (local.set $i (i32.add(local.get $i) (i32.const 1))) ;; $i += 1
      (br_if $continue (i32.lt_u (local.get $i) (global.get $num))) ;; $i < $num
    )

    (if
      (i32.gt_u (local.get $count) (i32.const 0)) ;; $count > 0
      (then
        (local.set $sum_pos_x
          (f64.div (local.get $sum_pos_x) (f64.convert_i32_u (local.get $count)))
        )
        (local.set $sum_pos_y
          (f64.div (local.get $sum_pos_y) (f64.convert_i32_u (local.get $count)))
        )
        (call $normalize
          (f64.sub (local.get $sum_pos_x) (local.get $pos_x))
          (f64.sub (local.get $sum_pos_y) (local.get $pos_y))
        )
        (call $limit
          (f64.sub
            (f64.mul
              (call $load_tmp_vector_x)
              (global.get $max_speed)
            )
            (call $load_vel_x (local.get $index))
          )
          (f64.sub
            (f64.mul
              (call $load_tmp_vector_y)
              (global.get $max_speed)
            )
            (call $load_vel_y (local.get $index))
          )
          (global.get $max_force)
        )
        (call $store_tmp_vector_x (call $load_tmp_vector_x))
        (call $store_tmp_vector_y (call $load_tmp_vector_y))
      )
      (else
        (call $store_tmp_vector_x (f64.const 0))
        (call $store_tmp_vector_y (f64.const 0))
      )
    )
  )

  (func
    (export "update")

    (local $i i32)
    (local $pos_x f64)
    (local $pos_y f64)
    (local $vel_x f64)
    (local $vel_y f64)
    (local $acc_x f64)
    (local $acc_y f64)

    (local.set $i (i32.const 0)) ;; $i = 0
    (loop $continue

      (local.set $acc_x (f64.const 0))
      (local.set $acc_y (f64.const 0))

      ;; add separation
      (call $separate (local.get $i))
      (local.set $acc_x
        (f64.mul
          (call $load_tmp_vector_x)
          (global.get $separation_intensity)
        )
      )
      (local.set $acc_y
        (f64.mul
          (call $load_tmp_vector_y)
          (global.get $separation_intensity)
        )
      )

      ;; add alignment
      (call $align (local.get $i))
      (local.set $acc_x
        (f64.add
          (local.get $acc_x)
          (f64.mul
            (call $load_tmp_vector_x)
            (global.get $align_intensity)
          )
        )
      )
      (local.set $acc_y
        (f64.add
          (local.get $acc_y)
          (f64.mul
            (call $load_tmp_vector_y)
            (global.get $align_intensity)
          )
        )
      )

      ;; add cohesion
      (call $cohesion (local.get $i))
      (local.set $acc_x
        (f64.add
          (local.get $acc_x)
          (f64.mul
            (call $load_tmp_vector_x)
            (global.get $cohesion_intensity)
          )
        )
      )
      (local.set $acc_y
        (f64.add
          (local.get $acc_y)
          (f64.mul
            (call $load_tmp_vector_y)
            (global.get $cohesion_intensity)
          )
        )
      )

      (call $store_acc_x (local.get $i) (local.get $acc_x))
      (call $store_acc_y (local.get $i) (local.get $acc_y))

      (local.set $i (i32.add (local.get $i) (i32.const 1))) ;; $i += 1
      (br_if $continue (i32.lt_u (local.get $i) (global.get $num))) ;; continue if: $i < $num
    )

    (local.set $i (i32.const 0)) ;; $i = 0
    (loop $continue

      (local.set $pos_x (call $load_pos_x (local.get $i)))
      (local.set $pos_y (call $load_pos_y (local.get $i)))
      (local.set $vel_x (call $load_vel_x (local.get $i)))
      (local.set $vel_y (call $load_vel_y (local.get $i)))
      (local.set $acc_x (call $load_acc_x (local.get $i)))
      (local.set $acc_y (call $load_acc_y (local.get $i)))

      (local.set $vel_x (f64.add (local.get $vel_x) (local.get $acc_x))) ;; $vel_x += $acc_x
      (local.set $vel_y (f64.add (local.get $vel_y) (local.get $acc_y))) ;; $vel_y += $acc_y
      (call $limit (local.get $vel_x) (local.get $vel_y) (global.get $max_speed))
      (local.set $vel_x (call $load_tmp_vector_x))
      (local.set $vel_y (call $load_tmp_vector_y))
      (local.set $pos_x (f64.add (local.get $pos_x) (local.get $vel_x))) ;; $vel_x += $acc_x
      (local.set $pos_y (f64.add (local.get $pos_y) (local.get $vel_y))) ;; $vel_y += $acc_y

      (if
        (f64.lt (local.get $pos_x) (f64.neg (global.get $radius))) ;; $pos_x < -$radius
        (then ;; $pos_x = $width + $radius
          (local.set $pos_x (f64.add (global.get $width) (global.get $radius)))
        )
      )
      (if
        (f64.gt (local.get $pos_x) (f64.add (global.get $width) (global.get $radius))) ;; $pos_x > $width + $radius
        (then ;; $pos_x = -$radius
          (local.set $pos_x (f64.neg (global.get $radius)))
        )
      )
      (if
        (f64.lt (local.get $pos_y) (f64.neg (global.get $radius))) ;; $pos_y < -$radius
        (then ;; $pos_y = $height + $radius
          (local.set $pos_y (f64.add (global.get $height) (global.get $radius)))
        )
      )
      (if
        (f64.gt (local.get $pos_y) (f64.add (global.get $height) (global.get $radius))) ;; $pos_y > $height + $radius
        (then ;; $pos_y = -$radius
          (local.set $pos_y (f64.neg (global.get $radius)))
        )
      )

      (call $store_pos_x (local.get $i) (local.get $pos_x))
      (call $store_pos_y (local.get $i) (local.get $pos_y))
      (call $store_vel_x (local.get $i) (local.get $vel_x))
      (call $store_vel_y (local.get $i) (local.get $vel_y))

      (local.set $i (i32.add (local.get $i) (i32.const 1))) ;; $i += 1
      (br_if $continue (i32.lt_u (local.get $i) (global.get $num))) ;; continue if: $i < $num
    )
  )

  (func $initialize
    (global.set $address_tmp_vector_x
      (i32.mul (global.get $num) (i32.const 48))
    )
    (global.set $address_tmp_vector_y
      (i32.add
        (i32.mul (global.get $num) (i32.const 48))
        (i32.const 8)
      )
    )
  )

  (start $initialize)
)